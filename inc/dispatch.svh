`ifndef DISPATCH_SVH
`define DISPATCH_SVH

`include "defs.svh"

interface dispatch #(
  WIDTH = 3
);
  bool      [WIDTH-1:0] rs_avail;
  rs_idx_t  [WIDTH-1:0] rs_idx;
  bool      [WIDTH-1:0] valid;
  opt_t     [WIDTH-1:0] opt;
  fun_t     [WIDTH-1:0] fun;
  sel_t     [WIDTH-1:0] [1:0] sel;
  pc_t      [WIDTH-1:0] pc;
  imm_t     [WIDTH-1:0] imm;
  phy_reg_t [WIDTH-1:0] [1:0] src;
  bool      [WIDTH-1:0] [1:0] ready;
  phy_reg_t [WIDTH-1:0] dst;
  rob_idx_t [WIDTH-1:0] rob_idx;
  bool      [WIDTH-1:0] sq_avail;
  sq_idx_t  [WIDTH-1:0] sq_idx;
  bool      [WIDTH-1:0] lq_avail;
  lq_idx_t  [WIDTH-1:0] lq_idx;

  modport rob(
    input avail,
    input rs_idx,
    output valid,
    output opt, 
    output fun,
    output sel,
    output pc,
    output imm,
    output src,
    output dst,
    output rob_idx
  );

  modport mt(
    input valid,
    input src,
    output ready
  );

  modport rs(
    output rs_avail,
    output rs_idx,
    input valid,
    input opt,
    input sel,
    input fun,
    input pc,
    input imm,
    input src,
    input ready,
    input dst,
    input rob_idx,
    input lq_idx,
    input sq_idx,
  );

  modport lq(
    output lq_avail,
    output lq_idx,
    input valid
  );

  modport sq(
    output sq_avail,
    output sq_idx,
    input valid
  );
endinterface

`endif // DISPATCH_SVH
