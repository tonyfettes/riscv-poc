`include "rename.svh"
`include "complete.svh"
`include "rewind.svh"
`include "retire.svh"

module mt #(
  SIZE = 32
) (
  input clock, reset,
  rename.mt rename,
  rewind.mt rewind,
  retire.mt retire,
  complete.mt complete
);

  typedef struct packed {
    phy_reg_t map;
    bool      ready;
  } entry_t;

  entry_t [SIZE-1:0] data;
  entry_t [SIZE-1:0] data_next;

  always_ff @(posedge clock) begin
    if (reset) begin
      for (int i = 0; i < SIZE; i++) begin
        data[i].map <= `SD i;
        data[i].ready <= `SD TRUE;
      end
    end else begin
      data <= `SD data_next;
    end
  end

  always_comb begin
    data_next = data;

    for (int c = 0; c < complete.WIDTH; c++) begin
      for (int i = 0; i < SIZE; i++) begin
        if (data_next[i].map == complete.dst[c]) begin
          data_next[i].ready = TRUE;
        end
      end
    end

    for (int r = 0; r < rename.WIDTH; r++) begin
      rename.phy_dst_old[r] = data_next[rename.arc_dst[r]];
      data_next[rename.arc_dst[r]] = rename.phy_dst[r];
    end
  end
endmodule
