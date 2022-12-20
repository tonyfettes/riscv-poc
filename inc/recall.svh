`ifndef RECALL_SVH
`define RECALL_SVH

interface recall;
  bool      valid;
  mem_idx_t idx;
  bool      found;
  mem_blk_t blk;

  modport vs(
    input  valid,
    input  idx,
    output found,
    output blk
  );

  modport ds(
    output valid,
    output idx,
    input  found,
    input  blk
  );
endinterface

`endif // RECALL_SVH
