`include "issue.svh"
`include "execute.svh"

module rf #(
  SIZE = 64
) (
  input clock, reset,
  issue.rf issue,
  execute.rf execute
);
  xlen_t [SIZE-1:0] data;
  xlen_t [SIZE-1:0] data_next;

  always_comb begin
    data_next = data;
    for (int i = 0; i < issue.WIDTH; i++) begin
      if (issue.valid[i]) begin
        if (issue.src[i] == 0) begin
          issue.ops[i] = 0;
        end else begin
          issue.ops[i] = data[issue.src[i]];
        end
      end
    end
    for (int i = 0; i < execute.WIDTH; i++) begin
      if (execute.valid[i]) begin
        data_next[execute.dst[i]] = execute.opd[i];
      end
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      data <= `SD 0;
    end else begin
      data <= `SD data_next;
    end
  end
endmodule
