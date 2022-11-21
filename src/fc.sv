`include "resolve.svh"
`include "predict.svh"
`include "fetch.svh"
`include "decode.svh"

module fc (
  input clock, reset,
  fetch.fc fetch,
  predict.fc predict,
  resolve.fc resolve,
  decode.fc decode
);
  pc_t [fetch.WIDTH-1:0] pc;
  pc_t [fetch.WIDTH-1:0] pc_next;

  assign fetch.pc = pc;

  localparam WIDTH = fetch.WIDTH < decode.WIDTH ?
    fetch.WIDTH : decode.WIDTH;

  inst_t [decode.WIDTH-1:0] inst;

  pc_t avail_count;

  always_comb begin
    avail_count = 0;
    for (int i = 0; i < decode.WIDTH; i++) begin
      if (decode.avail[i]) begin
        avail_count = avail_count + 1;
      end
    end
    // Decode
    for (int i = 0; i < WIDTH; i++) begin
      decode.valid[i] = fetch.valid[i];
      decode.inst[i] = fetch.data[i];
      decode.pc[i] = pc[i];
    end
    // Fetch
    for (int i = 0; i < WIDTH; i++) begin
      pc_next[i] = pc[i] + avail_count * 4;
      if (resolve.valid && resolve.right) begin
        pc_next[i] = resolve.dst + i * 4;
      end else if (predict.valid) begin
        pc_next[i] = predict.dst + i * 4;
      end
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      for (int i = 0; i < WIDTH; i++) begin
        pc[i] <= `SD pc_t'(i * 4);
      end
    end else begin
      pc <= `SD pc_next;
    end
  end
endmodule
