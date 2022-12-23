`ifndef LOAD_SVH
`define LOAD_SVH

interface load;
  bool      qry;
  mem_idx_t qry_mem_idx;
  lq_idx_t  qry_lq_idx;

  bool      ack;
  lq_idx_t  ack_head;

  bool      hit;
  mem_blk_t hit_blk;

  bool      ans;
  lq_idx_t  ans_head;
  mem_blk_t ans_blk;

  modport lq(
    output qry,
    output qry_mem_idx,
    output qry_lq_idx,

    input ack,
    input ack_head,

    input hit,
    input hit_blk,

    input ans,
    input ans_head,
    input ans_blk
  );

  modport ds(
    input qry,
    input qry_mem_idx,
    input qry_lq_idx,

    output ack,
    output ack_head,

    output hit,
    output hit_blk,

    output ans,
    output ans_head,
    output ans_blk
  );
endinterface

`endif // LOAD_SVH
