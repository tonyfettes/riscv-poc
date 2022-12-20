`include "defs.svh"
`include "fetch.svh"

// Banked Instruction Cache
module is #(
  parameter SIZE = 8,
  parameter BANK = 2
) (
  input clock, reset,
  fetch.is fetch,
  memory.dev memory,
  evict.cs evict,
);

  localparam BANK_SIZE = SIZE / BANK;
  assert fetch.WIDTH <= BANK * 2;

  // +-----+-----+-----+-----+-----+
  // | TAG | SET | BNK | BLK | OFF |
  // +-----+-----+-----+-----+-----+
  localparam OFF_LEN = 2;
  typedef logic [OFF_LEN-1:0] off_t;
  localparam BLK_LEN = 1;
  typedef logic [BLK_LEN-1:0] blk_t;
  localparam BNK_LEN = `IDX_LEN(BANK);
  typedef logic [BNK_LEN-1:0] bnk_t;
  localparam SET_LEN = `IDX_LEN(SIZE);
  typedef logic [SET_LEN-1:0] set_t;
  localparam TAG_LEN = `XLEN - OFF_LEN - BLK_LEN - BNK_LEN - SET_LEN;
  typedef logic [TAG_LEN-1:0] tag_t;

  typedef struct packed {
    bool      valid;
    tag_t     tag;
    mem_blk_t blk;
  } entry_t;

  entry_t [BANK_SIZE-1:0] data      [1:0];
  entry_t [BANK_SIZE-1:0] data_next [1:0];

  typedef struct packed {
    bool      valid;
    tag_t     tag;
    set_t     set;
    mem_tag_t mem_tag;
  } mshr_t;

  mshr_t [BANK-1:0] mshr, mshr_next;

  tag_t [fetch.WIDTH-1:0] tag;
  set_t [fetch.WIDTH-1:0] set;
  bnk_t [fetch.WIDTH-1:0] bnk;
  blk_t [fetch.WIDTH-1:0] blk;
  off_t [fetch.WIDTH-1:0] off;

  set_t [BANK-1:0] qry_set;
  tag_t [BANK-1:0] qry_tag;
  bnk_t [BANK-1:0] qry_bnk;

  xlen_t [BANK-1:0] [1:0] ans;
  bool   [BANK-1:0]       ans_valid;

  always_comb begin
    data_next = data;
    mshr_next = mshr;

    for (int i = 0; i < fetch.WIDTH; i++) begin
      {tag[i], set[i], bnk[i], blk[i], off[i]} = pc + i * 4;
    end

    for (int i = 0; i < BANK; i++) begin
      {qry_tag[bnk[0] + i], qry_set[bnk[0] + i], _} =
        {tag[0], set[0], bnk[0]} + i;
    end

    memory = '0;
    for (int i = 0; i < BANK; i++) begin
      if (
        data[i][qry_set[i]].valid &&
        data[i][qry_set[i]].tag == qry_tag[i]
      ) begin
        ans_valid[i] = TRUE;
        ans[i] = data[i][qry_set[i]].blk
      end else if (!(
        mshr[i].valid &&
        mshr[i].set == qry_set[i] &&
        mshr[i].tag == qry_tag[i]
      )) begin
        memory.qry_cmd = MEM_CMD_LOAD;
        memory.qry_blk = '0;
        memory.qry_idx = {qry_tag[i], qry_set[i], bnk_t'(i)};
        if (memory.ack) begin
          mshr_next[i].valid = TRUE;
          mshr_next[i].tag = qry_tag[i];
          mshr_next[i].set = qry_set[i];
          mshr_next[i].mem_tag = memory.ack;
        end
      end
    end

    for (int i = 0; i < fetch.WIDTH; i++) begin
      fetch.valid[i] = bnk_valid[bnk[i]];
      fetch.data[i] = bnk_data[bnk[i]][blk[i]];
    end

    for (int i = 0; i < BANK; i++) begin
      if (mshr[i].valid && memory.ans_tag == mshr[i].mem_tag) begin
        if (data[i][mshr[i].set].valid) begin
          if (data[i][mshr[i].set].tag != mshr[i].mem_tag) begin
            evict.valid = TRUE;
            evict.idx = {mshr[i].tag, mshr[i].set, bnk_t'(i)};
            evict.blk = data_next[i][mshr[i].set].blk;
            data_next[i][mshr[i].set].tag = mshr[i].tag;
            data_next[i][mshr[i].set].blk = memory.ans_blk;
          end else begin
            data_next[i][mshr[i].set].blk = memory.ans_blk;
          end
        end else begin
          data_next[i][mshr[i].set].valid = TRUE;
          data_next[i][mshr[i].set].tag = mshr[i].tag;
          data_next[i][mshr[i].set].blk = memory.ans_blk;
        end
      end
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
