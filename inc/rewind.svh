`ifndef REWIND_SVH
`define REWIND_SVH

`include "defs.svh"

interface rewind #(
  WIDTH = 3
);
  logic     [WIDTH-1:0] valid;
  arc_reg_t [WIDTH-1:0] arc_dst;
  phy_reg_t [WIDTH-1:0] phy_dst;
  phy_reg_t [WIDTH-1:0] phy_dst_old;
  rs_idx_t  [WIDTH-1:0] rs_idx;

  modport rob(
    output valid,
    output rs_idx,
    output arc_dst,
    output phy_dst,
    output phy_dst_old
  );

  modport mt(
    input valid,
    input arc_dst,
    input phy_dst_old
  );

  modport fl(
    input valid,
    input phy_dst
  );

  modport rs(
    input valid,
    input rs_idx
  );
endinterface

`endif // REWIND_SVH
