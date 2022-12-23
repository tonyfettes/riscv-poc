`include "defs.svh"
`include "memory.svh"
`include "evict.svh"
`include "load.svh"

module ds #(
  parameter SIZE = 8,
  parameter WAY = 2
) (
  input clock, reset,
  memory.dev memory,
  evict.cs evict,
  load.ds load
);
  localparam SET_LEN = `IDX_LEN(SIZE); 
  typedef logic [SET_LEN-1:0] set_t;
  localparam TAG_LEN = `MEM_IDX_LEN - SET_LEN;
  typedef logic [TAG_LEN-1:0] tag_t;

  localparam WAY_LEN = `IDX_LEN(WAY);
  typedef logic [WAY_LEN-1:0] way_t;

`ifdef DS_LRU
  localparam LRU_LEN = `IDX_LEN(WAY);
  typedef logic [LRU_LEN-1:0] lru_t;
`endif
`ifdef DS_NMRU
  typedef bool mru_t;
`endif

  typedef struct packed {
    bool  valid;
    tag_t tag;
  `ifdef DS_LRU
    lru_t lru;
  `endif
  `ifdef DS_NMRU
    mru_t mru;
  `endif
    mem_blk_t blk;
  } entry_t;

  entry_t [SIZE-1:0] [WAY-1:0] data, data_next;
  bool  [SIZE-1:0] cand_valid;
  way_t [SIZE-1:0] cand;

  // +----+    +------+    +----+
  // | SQ | <- | MSHR | -> | LQ |
  // +----+    +------+    +----+
  typedef struct packed {
    bool      valid;
    tag_t     tag;
    set_t     set;
    bool      lq_valid;
    lq_idx_t  lq_idx;
    bool      sq_valid;
    sq_idx_t  sq_idx;
  } mshr_t;

  mshr_t [memory.DEPTH:1] mshr, mshr_next;
  set_t mshr_set;

  tag_t load_tag;
  set_t load_set;

  always_comb begin
    evict.valid = FALSE;
    evict.idx = 0;
    evict.blk = 0;

    memory.qry_cmd = MEM_CMD_NONE;
    memory.qry_blk = 0;
    memory.qry_idx = 0;

    load.hit = FALSE;
    load.hit_blk = 0;
    load.ack = FALSE;
    load.ack_head = 0;
    if (load.qry) begin
      {load_tag, load_set} = load.qry_mem_idx;
      for (int j = 0; j < WAY; j++) begin
        if (data[load_set][j].tag == load_tag) begin
          load.hit = TRUE;
          load.hit_blk = data[load_set][j].blk;
        end
      end
      if (!load.hit) begin
        for (int j = 1; j <= memory.DEPTH; j++) begin
          if (mshr[j].valid &&
              mshr[j].tag == load_tag &&
              mshr[j].set == load_set) begin
            load.ack = TRUE;
            if (mshr[j].lq_valid) begin
              load.ack_head = mshr[j].lq_idx;
            end else begin
              load.ack_head = load.qry_lq_idx;
            end
	    mshr_next[j].lq_valid = TRUE;
            mshr_next[j].lq_idx = load.qry_lq_idx;
          end
        end
      end
      if (!load.hit && !load.ack &&
          memory.qry_cmd == MEM_CMD_NONE) begin
        memory.qry_cmd = MEM_CMD_LOAD;
        memory.qry_blk = 0;
        memory.qry_idx = {load_tag, load_set};
        if (memory.ack) begin
          load.ack = TRUE;
          mshr_next[memory.ack].valid = TRUE;
          mshr_next[memory.ack].tag = load_tag;
          mshr_next[memory.ack].set = load_set;
          mshr_next[memory.ack].sq_valid = FALSE;
          mshr_next[memory.ack].sq_idx = 0;
          mshr_next[memory.ack].lq_valid = TRUE;
          mshr_next[memory.ack].lq_idx = load.qry_lq_idx;
        end
      end
    end

    for (int i = 0; i < SIZE; i++) begin
      cand_valid[i] = FALSE;
      for (int j = 0; j < WAY; j++) begin
        if (!data[i][j].valid) begin
          cand[i] = j;
          cand_valid[i] = TRUE;
        end
      end
      if (!cand_valid) begin
      `ifdef DS_LRU
        for (int j = 0; j < WAY; j++) begin
          if (data[i][j].lru == {LRU_LEN{1'b1}}) begin
            cand[i] = j;
          end
        end
      `endif
      `ifdef DS_NMRU
        for (int j = 0; j < WAY; j++) begin
          if (!data[i][j].mru) begin
            cand[i] = j;
          end
        end
      `endif
      end
    end

    load.ans = FALSE;
    load.ans_head = 0;
    load.ans_blk = 0;
    if (memory.ans_tag != 0 && mshr[memory.ans_tag].valid) begin
      mshr_next[memory.ans_tag] = 0;
      load.ans = mshr[memory.ans_tag].lq_valid;
      load.ans_head = mshr[memory.ans_tag].lq_idx;
      load.ans_blk = memory.ans_blk;

      // walk.sq_valid = mshr[memory.ans_tag].sq_valid;
      // walk.sq_idx = mshr[memory.ans_tag].sq_idx;
      // walk.blk = memory.ans_blk;
      mshr_set = mshr[memory.ans_tag].set;
      if (data[mshr_set][cand[mshr_set]].valid) begin
        evict.valid = TRUE;
        evict.idx = { data[mshr_set][cand[mshr_set]].tag, mshr_set };
        evict.blk = data[mshr_set][cand[mshr_set]].blk;
      end
      data_next[mshr_set][cand[mshr_set]].valid = TRUE;
      data_next[mshr_set][cand[mshr_set]].blk = memory.ans_blk;
      data_next[mshr_set][cand[mshr_set]].tag =
        mshr[memory.ans_tag].tag;
    `ifdef DS_LRU
      for (int i = 0; i < WAY; i++) begin
        if (i != cand[mshr_set]) begin
          data_next[mshr_set][i].lru = data[mshr_set][i].lru + 1;
        end else begin
          data_next[mshr_set][i].lru = 0;
        end
      end
    `endif
    `ifdef DS_NMRU
      for (int i = 0; i < WAY; i++) begin
        if (i != cand[mshr_set]) begin
          data_next[mshr_set][i].mru = FALSE;
        end else begin
          data_next[mshr_set][i].mru = TRUE;
        end
      end
    `endif
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      data <= `SD 0;
      mshr <= `SD 0;
    end else begin
      data <= `SD data_next;
      mshr <= `SD mshr_next;
    end
  end
endmodule
