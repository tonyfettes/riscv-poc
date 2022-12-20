`ifndef SUBMIT_SVH
`define SUBMIT_SVH

`include "defs.svh"

interface submit #(
  WIDTH = 3
);
  logic     [WIDTH-1:0] valid;
  fu_op_t   [WIDTH-1:0] fu_op;
  fu_sel_t  [WIDTH-1:0] fu_sel;
  pc_t      [WIDTH-1:0] pc;
  imm_t     [WIDTH-1:0] imm;
  phy_reg_t [WIDTH-1:0] [1:0] src;
  logic     [WIDTH-1:0] [1:0] ready;
  phy_reg_t [WIDTH-1:0] dst;
  phy_reg_t [WIDTH-1:0] dst_old;

  modport mt(
    output valid,
    output fu_op,
    output fu_sel,
    output pc,
    output imm,
    output src,
    output ready,
    output dst,
    output dst_old
  );

  modport rob(
    input valid,
    input fu_op,
    input fu_sel,
    input pc,
    input imm,
    input src,
    input ready,
    input dst,
    input dst_old
  );
endinterface

`endif // SUBMIT_SVH
