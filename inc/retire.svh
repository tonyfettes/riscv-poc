`ifndef RETIRE_SVH
`define RETIRE_SVH

`include "defs.svh"

interface retire #(
  parameter WIDTH = 3
);
  bool      [WIDTH-1:0] avail;
  bool      [WIDTH-1:0] valid;
  opt_t     [WIDTH-1:0] opt;
  fun_t     [WIDTH-1:0] fun;
  arc_reg_t [WIDTH-1:0] arc_dst;
  phy_reg_t [WIDTH-1:0] phy_dst;
  phy_reg_t [WIDTH-1:0] phy_dst_old;

  modport rob(
    input avail,
    output valid,
    output opt,
    output fun,
    output arc_dst,
    output phy_dst,
    output phy_dst_old
  );

  modport mt(
    input valid,
    input arc_dst,
    input phy_dst
  );

  modport fl(
    input valid,
    input phy_dst_old
  );

  modport sq(
    output avail,
    input valid,
    input opt,
    input fun
  );
endinterface

`endif // RETIRE_SVH
