`ifndef COMPLETE_SVH
`define COMPLETE_SVH

`include "defs.svh"

interface complete #(
  WIDTH = 3
);
  bool      [WIDTH-1:0] valid;
  phy_reg_t [WIDTH-1:0] dst;
  rob_idx_t [WIDTH-1:0] rob_idx;
  bool      [WIDTH-1:0] exc_valid;
  exc_t     [WIDTH-1:0] exc;

  modport cq(
    output valid,
    output dst,
    output rob_idx,
    output exc_valid,
    output exc
  );

  modport rs(
    input valid,
    input dst
  );

  modport rob(
    input valid,
    input rob_idx,
    input exc_valid,
    input exc
  );

  modport mt(
    input valid,
    input dst
  );
endinterface

`endif // COMPLETE_SVH
