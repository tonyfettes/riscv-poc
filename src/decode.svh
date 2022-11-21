`ifndef DECODE_SVH
`define DECODE_SVH

`include "defs.svh"

interface decode #(
  WIDTH = 3
);
  bool      [WIDTH-1:0] avail;
  bool      [WIDTH-1:0] valid;
  inst_t    [WIDTH-1:0] inst;
  opt_t     [WIDTH-1:0] opt;
  fun_t     [WIDTH-1:0] fun;
  sel_t     [WIDTH-1:0] [1:0] sel;
  pc_t      [WIDTH-1:0] pc;
  imm_t     [WIDTH-1:0] imm;
  arc_reg_t [WIDTH-1:0] [1:0] src;
  arc_reg_t [WIDTH-1:0] dst;
  exc_t     [WIDTH-1:0] exc;

  modport fc(
    input avail,
    output valid,
    output inst,
    output pc
  );

  modport dc(
    input valid,
    input inst,
    input pc,
    output opt,
    output fun,
    output sel,
    output imm,
    output src,
    output dst,
    output exc
  );

  modport ib(
    output avail,
    input valid,
    input opt,
    input fun,
    input sel,
    input pc,
    input imm,
    input src,
    input dst,
    input exc
  );
endinterface

`endif // DECODE_SVH
