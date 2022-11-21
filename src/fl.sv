`include "rename.svh"
`include "rewind.svh"
`include "retire.svh"

module fl #(
  SIZE = 64
) (
  input clock, reset,
  rename.fl rename,
  retire.fl retire,
  rewind.fl rewind
);
  localparam IDX_LEN = `IDX_LEN(SIZE);

  typedef logic [IDX_LEN-1:0] idx_t;

  phy_reg_t [SIZE-1:0] data;
  phy_reg_t [SIZE-1:0] data_next;

  idx_t head;
  idx_t head_next;
  idx_t tail;
  idx_t tail_next;
  bool empty;
  bool empty_next;

  always_comb begin
    head_next  = head;
    tail_next  = tail;
    empty_next = empty;
    data_next  = data;

    for (int i = 0; i < retire.WIDTH; i++) begin
      if (retire.valid[i] && (empty_next || tail_next != head_next)) begin
        data_next[tail_next] = retire.phy_dst_old[i];
        tail_next = (tail_next + 1) % SIZE;
        empty_next = FALSE;
      end
    end

    for (int i = 0; i < rewind.WIDTH; i++) begin
      if (rewind.valid[i] && (empty_next || tail_next != head_next)) begin
        data_next[tail_next] = rewind.phy_dst[i];
        tail_next = (tail_next + 1) % SIZE;
        empty_next = FALSE;
      end
    end

    rename.phy_dst = 0;
    for (int i = 0; i < rename.WIDTH; i++) begin
      if (rename.valid[i] && empty_next == FALSE) begin
        rename.phy_dst[i] = data_next[head_next];
        head_next = (head_next + 1) % SIZE;
        if (head_next == tail_next) begin
          empty_next = TRUE;
        end
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      head  <= `SD '0;
      tail  <= `SD '0;
      empty <= `SD TRUE;
      for (int i = 0; i < SIZE; i++) begin
        data[i] <= `SD i + 32;
      end
    end else begin
      head  <= `SD head_next;
      tail  <= `SD tail_next;
      empty <= `SD empty_next;
      data  <= `SD data_next;
    end
  end
endmodule
