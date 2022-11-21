`include "resolve.svh"
`include "predict.svh"

module bp #(
  parameter SIZE = 32
) (
  input clock, reset,
  resolve.bp resolve,
  predict.bp predict
);
  localparam IDX_LEN = `IDX_LEN(SIZE);
  localparam TAG_LEN = `XLEN - IDX_LEN;

  typedef logic [TAG_LEN-1:0] tag_t;
  typedef logic [IDX_LEN-1:0] idx_t;

  typedef enum logic [1:0] {
    BP_SN = 2'b00,
    BP_WN = 2'b01,
    BP_WT = 2'b10,
    BP_ST = 2'b11
  } state_t;

  typedef struct packed {
    tag_t tag;
    pc_t pc;
    state_t state;
  } entry_t;

  entry_t [SIZE-1:0] data;
  entry_t [SIZE-1:0] data_next;

  idx_t fpc_idx;
  tag_t fpc_tag;
  idx_t rpc_idx;
  tag_t rpc_tag;

  assign fpc_idx = predict.src[IDX_LEN-1:0];
  assign fpc_tag = predict.src[`PC_LEN-1:IDX_LEN];
  assign rpc_idx = resolve.src[IDX_LEN-1:0];
  assign rpc_tag = resolve.src[`PC_LEN-1:IDX_LEN];

  always_comb begin
    data_next = data;

    if (predict.valid) begin
      if (data[fpc_idx].tag == fpc_tag) begin
        case (data[fpc_idx].state)
          BP_SN,
          BP_WN: predict.dst = predict.src + 4;
          BP_WT,
          BP_ST: predict.dst = data[fpc_idx].pc;
        endcase
      end else begin
        predict.dst = predict.src + 4;
      end
    end

    resolve.right = FALSE;
    if (resolve.valid) begin
      if (data[rpc_idx].tag == rpc_tag) begin
        case (data[rpc_idx].state)
          BP_SN,
          BP_WN:
            resolve.right = (resolve.taken == FALSE);
          BP_WT,
          BP_ST: begin
            resolve.right =
              (resolve.taken == TRUE &&
                resolve.dst == data[rpc_idx].pc);
            data_next[rpc_idx].pc = resolve.dst;
          end
        endcase
        if (resolve.taken) begin
          if (data[rpc_idx].state != BP_ST) begin
            data_next[rpc_idx].state =
              data[rpc_idx].state + 1;
          end
        end else if (!resolve.taken) begin
          if (data[rpc_idx].state != BP_SN) begin
            data_next[rpc_idx].state =
              data[rpc_idx].state - 1;
          end
        end
      end else begin
        resolve.right = TRUE;
        data_next[rpc_idx].tag = rpc_tag;
        data_next[rpc_idx].state = BP_SN;
        data_next[rpc_idx].pc = resolve.dst;
      end
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      data <= `SD 0;
    end else begin
      data <= `SD data_next;
    end
  end
endmodule
