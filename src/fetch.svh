`ifndef FETCH_SVH
`define FETCH_SVH

`include "defs.svh"

interface fetch #(
  parameter WIDTH = 3
);
  pc_t   [WIDTH-1:0] pc;
  xlen_t [WIDTH-1:0] data;
  bool   [WIDTH-1:0] valid;

  modport is(
    input pc,
    output data,
    output valid
  );

  modport fc(
    output pc,
    input data,
    input valid
  );
endinterface

`endif // FETCH_SVH
