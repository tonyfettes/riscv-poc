`ifndef ISSUE_SVH
`define ISSUE_SVH

`include "defs.svh"

interface issue #(
  parameter WIDTH = 3
);
  logic     [WIDTH-1:0] avail;
  bool      [WIDTH-1:0] valid;
  logic     [WIDTH-1:0] opi;
  fun_t     [WIDTH-1:0] fun;
  sel_t     [WIDTH-1:0] [1:0] sel;
  aux_t     [WIDTH-1:0] aux;
  imm_t     [WIDTH-1:0] imm;
  phy_reg_t [WIDTH-1:0] [1:0] src;
  xlen_t    [WIDTH-1:0] [1:0] ops;
  phy_reg_t [WIDTH-1:0] dst;

  modport rs(
    input avail,
    output valid,
    output opi,
    output fun,
    output sel,
    output aux,
    output imm,
    output src,
    output dst
  );

  modport rf(
    input valid,
    input src,
    output ops
  );

  modport fu(
    output avail,
    input valid,
    input opi,
    input fun,
    input sel,
    input aux,
    input imm,
    input ops,
    input dst
  );
endinterface

`endif // ISSUE_SVH
