`ifndef EXCEPT_SVH
`define EXCEPT_SVH

`include "defs.svh"

interface except;
  bool valid;
  exc_t code;

  modport rob(
    output valid,
    output code
  );
endinterface

`endif // EXCEPT_SVH
