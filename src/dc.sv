`include "decode.svh"
`include "predict.svh"

module dc (
  decode.dc decode,
  predict.dc predict
);
  generate
    for (genvar i = 0; i < decode.WIDTH; i++) begin
      dci dcs (
        .valid(decode.valid[i]),
        .inst(decode.inst[i]),
        .opt(decode.opt[i]),
        .fun(decode.fun[i]),
        .sel(decode.sel[i]),
        .imm(decode.imm[i]),
        .src(decode.src[i]),
        .dst(decode.dst[i]),
        .exc(decode.exc[i])
      );
    end
  endgenerate

  always_comb begin
    predict.valid = FALSE;
    predict.src = '0;
    for (int i = decode.WIDTH - 1; i >= 0; i--) begin
      if (decode.opt[i] == OPT_BRC) begin
        predict.valid = TRUE;
        predict.src = decode.pc[i];
      end
    end
  end
endmodule
