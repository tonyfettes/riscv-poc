`include "defs.svh"

module sc #(
  WIDTH = 2
) (
  input [WIDTH-1:0] state,
  input pc_t bpc,
  input pc_t ppc,
  output bool taken,
  output pc_t tpc
);

  localparam SIZE = int'($pow(WIDTH, 2));

  always_comb begin
    if (state < SIZE) begin
      taken = FALSE;
      tpc = bpc + 4;
    end else begin
      taken = TRUE;
      tpc = ppc;
    end
  end
endmodule
