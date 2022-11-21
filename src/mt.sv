`include "complete.svh"
`include "rewind.svh"
`include "retire.svh"

module mt #(
  SIZE = 32,
  WIDTH = 6
) (
  input clock, reset,
  rewind.mt rewind,
  retire.mt retire,
  complete.mt complete
);
endmodule
