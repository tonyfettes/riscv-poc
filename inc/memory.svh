`ifndef MEMORY_SVH
`define MEMORY_SVH

interface memory;
  localparam DEPTH = 15;
  mem_cmd_t qry_cmd;
  mem_blk_t qry_blk;
  mem_idx_t qry_idx;

  mem_tag_t ack;

  mem_blk_t ans_blk;
  mem_tag_t ans_tag;

  modport dev(
    output qry_cmd,
    output qry_blk,
    output qry_idx,
    input  ack,
    input  ans_blk,
    input  ans_tag
  );

  modport bus(
    input  qry_cmd,
    input  qry_blk,
    input  qry_idx,
    output ack,
    output ans_blk,
    output ans_tag
  );
endinterface

`endif // MEMORY_SVH
