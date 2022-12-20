`ifndef EXECUTE_SVH
`define EXECUTE_SVH

`include "defs.svh"

interface execute #(
  WIDTH = 3
);
  bool      [WIDTH-1:0] avail;
  bool      [WIDTH-1:0] valid;
  phy_reg_t [WIDTH-1:0] dst;
  rob_idx_t [WIDTH-1:0] rob_idx;
  xlen_t    [WIDTH-1:0] opd;
  bool      [WIDTH-1:0] exc_valid;
  exc_t     [WIDTH-1:0] exc;

  modport fu(
    input avail,
    output valid,
    output dst,
    output opd
  );

  modport rf(
    input valid,
    input dst,
    input opd
  );

  modport cq(
    output avail,
    input valid,
    input dst,
    input rob_idx,
    input exc_valid,
    input exc
  );
endinterface

`endif // EXECUTE_SVH
