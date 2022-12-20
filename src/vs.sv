`include "defs.svh"
`include "evict.svh"

// Victim Cache
module vs #(
  parameter SIZE = 8
) (
  input clock, reset,
  evict.vs evict,
  recall.vs recall,

  output logic [1:0] t_command,
  output logic [63:0] t_data,
  output logic [31:0] t_addr,

  input [3:0]  r_response,
  input [63:0] r_data,
  input [3:0]  r_tag
);
  typedef struct packed {
    bool      valid;
    bool      dirty;
    mem_idx_t idx;
    mem_blk_t blk;
  } entry_t;

  entry_t [SIZE-1:0] data, data_next;

  typedef logic [`IDX_LEN(SIZE)-1:0] idx_t;

  idx_t head, head_next;
  idx_t tail, tail_next;
  idx_t empty, empty_next;

  always_comb begin
    data_next = data;
    head_next = head;
    tail_next = tail;
    empty_next = empty;

    recall.found = FALSE;
    recall.blk = 0;
    if (recall.valid) begin
      for (int i = 0; i < SIZE; i++) begin
        if (data[i].valid && data[i].idx == recall.idx) begin
          recall.found = TRUE;
          recall.blk = data[i].blk;
        end
      end
    end

    if (evict.valid) begin
      if (head == tail && !empty) begin
        if (data[head].dirty) begin
          t_command = MEM_CMD_STORE;
          t_data = data[head].blk;
          t_addr = {data[head].idx, 3'b000};
          if (r_response != 0) begin
            data_next[tail].valid = TRUE;
            data_next[tail].dirty = evict.dirty;
            data_next[tail].idx = evict.idx;
            data_next[tail].blk = evict.blk;
            tail_next = (tail + 1) % SIZE;
            head_next = (head + 1) % SIZE;
          end
        end else begin
          data_next[tail].valid = TRUE;
          data_next[tail].dirty = evict.dirty;
          data_next[tail].idx = evict.idx;
          data_next[tail].blk = evict.blk;
          head_next = (head + 1) % SIZE;
          tail_next = (tail + 1) % SIZE;
        end
      end else begin
        data_next[tail].valid = TRUE;
        data_next[tail].dirty = evict.dirty;
        data_next[tail].idx = evict.idx;
        data_next[tail].blk = evict.blk;
        tail_next = (tail + 1) % SIZE;
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      data  <= `SD 0;
      head  <= `SD 0;
      tail  <= `SD 0;
      empty <= `SD `TRUE;
    end else begin
      data  <= `SD data_next;
      head  <= `SD head_next;
      tail  <= `SD tail_next;
      empty <= `SD empty_next;
    end
  end
endmodule
