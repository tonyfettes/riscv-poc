`include "defs.svh"

module lsq #(
  parameter WIDTH = 1
) (
  input  xlen_t   [WIDTH-1:0] address,
  output xlen_t   [WIDTH-1:0] content,
  output lq_idx_t [WIDTH-1:0] lq_tail,
  output sq_idx_t [WIDTH-1:0] sq_tail,
);
endmodule
