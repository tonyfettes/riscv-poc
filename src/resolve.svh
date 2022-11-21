`ifndef RESOLVE_SVH
`define RESOLVE_SVH

`include "defs.svh"

interface resolve;
  bool      valid;
  bool      taken;
  bool      right;
  pc_t      src;
  pc_t      dst;
  rob_idx_t rob_idx;

  modport fu(
    output valid,
    output src,
    output dst,
    output taken,
    output rob_idx
  );

  modport bp(
    input valid,
    input src,
    input dst,
    input taken,
    output right
  );

  modport rob(
    input valid,
    input right,
    input rob_idx
  );

  modport fc(
    input valid,
    input right,
    input dst
  );

  modport ib(
    input valid,
    input right
  );
endinterface

`endif // RESOLVE_SVH
