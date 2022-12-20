`ifndef FETCH_SVH
`define FETCH_SVH

`include "defs.svh"

interface fetch #(
  parameter WIDTH = 3
);
  bool   enable;
  addr_t pc;
  xlen_t [WIDTH-1:0] data;
  bool   [WIDTH-1:0] valid;

  modport is(
    input enable,
    input pc,
    output data,
    output valid
  );

  modport fc(
    output enable,
    output pc,
    input data,
    input valid
  );
endinterface

`endif // FETCH_SVH
