`include "decode.svh"
`include "rename.svh"
`include "resolve.svh"

module ib #(
  parameter SIZE = 16
) (
  input clock, reset,
  decode.ib decode,
  rename.ib rename,
  resolve.ib resolve
);
  localparam IDX_LEN = `IDX_LEN(SIZE);
  typedef logic [IDX_LEN-1:0] idx_t;

  typedef struct packed {
    opt_t     opt;
    fun_t     fun;
    sel_t     [1:0] sel;
    pc_t      pc;
    imm_t     imm;
    arc_reg_t [1:0] src;
    arc_reg_t dst;
    exc_t     exc;
  } entry_t;

  entry_t [SIZE-1:0] data;
  entry_t [SIZE-1:0] data_next;

  idx_t head;
  idx_t head_next;
  idx_t tail;
  idx_t tail_next;

  bool empty;
  bool empty_next;

  always_comb begin
    data_next = data;
    head_next = head;
    tail_next = tail;
    empty_next = empty;
    for (int i = 0; i < decode.WIDTH; i++) begin
      if (empty_next == TRUE ||
          ((head_next + i) % SIZE != tail_next)) begin
        decode.avail[i] = TRUE;
      end
    end
    for (int i = 0; i < decode.WIDTH; i++) begin
      if (decode.valid[i]) begin
        data[tail_next].opt = decode.opt[i];
        data[tail_next].fun = decode.fun[i];
        data[tail_next].sel = decode.sel[i];
        data[tail_next].pc  = decode.pc[i];
        data[tail_next].imm = decode.imm[i];
        data[tail_next].src = decode.src[i];
        data[tail_next].dst = decode.dst[i];
        data[tail_next].exc = decode.exc[i];
        tail_next = (tail_next + 1) % SIZE;
      end
    end
    for (int i = 0; i < rename.WIDTH; i++) begin
      if (rename.avail[i] && empty_next == FALSE) begin
        rename.valid[i]   = TRUE;
        rename.opt[i]     = data[head_next].opt;
        rename.fun[i]     = data[head_next].fun;
        rename.sel[i]     = data[head_next].sel;
        rename.pc[i]      = data[head_next].pc;
        rename.imm[i]     = data[head_next].imm;
        rename.src[i]     = data[head_next].src;
        rename.arc_dst[i] = data[head_next].dst;
        head_next = (head_next + 1) % SIZE;
        if (head_next == tail_next) begin
          empty_next = TRUE;
        end
      end
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset || (resolve.valid && !resolve.right)) begin
      data  <= `SD '0;
      head  <= `SD '0;
      tail  <= `SD '0;
      empty <= `SD TRUE;
    end else begin
      data  <= `SD data_next;
      head  <= `SD head_next;
      tail  <= `SD tail_next;
      empty <= `SD empty_next;
    end
  end
endmodule
