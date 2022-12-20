`ifndef PREDICT_SVH
`define PREDICT_SVH

`include "defs.svh"

interface predict;
  bool valid;
  pc_t src;
  pc_t dst;

  modport bp (
    input valid,
    input src,
    output dst
  );

  modport fc (
    input valid,
    input dst
  );

  modport dc (
    output valid,
    output src
  );
endinterface

`endif // PREDICT_SVH
