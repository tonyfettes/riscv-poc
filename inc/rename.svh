`ifndef RENAME_SVH
`define RENAME_SVH

`include "defs.svh"

interface rename #(
  WIDTH = 3
);
  bool      [WIDTH-1:0] avail;
  bool      [WIDTH-1:0] valid;
  opt_t     [WIDTH-1:0] opt;
  fun_t     [WIDTH-1:0] fun;
  sel_t     [WIDTH-1:0] [1:0] sel;
  pc_t      [WIDTH-1:0] pc;
  imm_t     [WIDTH-1:0] imm;
  arc_reg_t [WIDTH-1:0] [1:0] src;
  arc_reg_t [WIDTH-1:0] arc_dst;
  phy_reg_t [WIDTH-1:0] phy_dst;
  phy_reg_t [WIDTH-1:0] phy_dst_old;

  modport ib(
    input avail,
    output valid,
    output opt,
    output fun,
    output sel,
    output pc,
    output imm,
    output src,
    output arc_dst
  );

  modport fl(
    input valid,
    output phy_dst
  );

  modport mt(
    input valid,
    input arc_dst,
    input phy_dst,
    output phy_dst_old
  );

  modport rob(
    output avail,
    input valid,
    input opt,
    input fun,
    input sel,
    input pc,
    input imm,
    input src,
    input arc_dst,
    input phy_dst,
    input phy_dst_old
  );
endinterface

`endif // RENAME_SVH
