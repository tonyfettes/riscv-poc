`ifndef EVICT_SVH
`define EVICT_SVH

interface evict;
  bool      valid;
  mem_idx_t idx;
  mem_blk_t blk;

  modport vs(
    input valid,
    input idx,
    input blk
  );

  modport cs(
    output valid,
    output idx,
    output blk
  );
endinterface

`endif // EVICT_SVH
