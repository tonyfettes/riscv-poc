`ifndef CACHE_SVH
`define CACHE_SVH

`include "defs.svh"

interface cache;
  bool     valid;
  addr_t   addr;
  xlen_t   data;

  bool     accepted;

  modport f(
    output valid,
    output addr,
    output data,
    input  accepted
  );

  modport s(
    input  valid,
    input  addr,
    input  data,
    output accepted
  );
endinterface

`endif // CACHE_SVH
