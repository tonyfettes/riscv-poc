`include "execute.svh"
`include "resolve.svh"

module brc(
  input valid,
  input xlen_t [1:0] ops,
  input brc_fun_t fun,

  output bool taken
);

  slen_t [1:0] sops;
  assign sops = ops;

  always_comb begin
    if (valid == FALSE) begin
      taken = FALSE;
    end else if (fun.ty == BRC_JUMP) begin
      taken = TRUE;
    end else begin
      case (fun.branch)
        BRC_BEQ:  taken = (sops[0] == sops[1]);
        BRC_BNE:  taken = (sops[0] != sops[1]);
        BRC_BLT:  taken = (sops[0] <  sops[1]);
        BRC_BGE:  taken = (sops[0] >= sops[1]);
        BRC_BLTU: taken = ( ops[0] <   ops[1]);
        BRC_BGEU: taken = ( ops[0] >=  ops[1]);
        default:  taken = FALSE;
      endcase
    end
  end
endmodule
