`include "memory.svh"

// Memory Sequencer
module ms #(
  parameter WIDTH = 3
) (
  input clock, reset,
  memory.bus [WIDTH-1:0] dev,
  memory.dev mem
);
  always_comb begin
    for (int i = 0; i < WIDTH; i++) begin
      if (dev[i].cmd) begin
        mem.qry_cmd = dev[i].qry_cmd;
        mem.qry_blk = dev[i].qry_blk;
        mem.qry_idx = dev[i].qry_idx;
        dev[i].ack = mem.ack;
      end
      dev[i].ans_blk = mem.ans_blk;
      dev[i].ans_tag = mem.ans_tag;
    end
  end
endmodule
