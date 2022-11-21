`include "execute.svh"

module alu(
  input bool valid,
  input xlen_t [1:0] ops,
  input alu_fun_t fun,

  output xlen_t opd
);
  slen_t [1:0] sops;
  assign sops = ops;

  always_comb begin
    if (valid) begin
      case (fun)
        ALU_ADD:  opd = ops[0] + ops[1];
        ALU_SUB:  opd = ops[0] - ops[1];
        ALU_SLT:  opd = sops[0] < sops[1];
        ALU_SLTU: opd = ops[0] < ops[1];
        ALU_AND:  opd = ops[0] & ops[1];
        ALU_OR:   opd = ops[0] | ops[1];
        ALU_XOR:  opd = ops[0] ^ ops[1];
        ALU_SRL:  opd = ops[0] >> ops[1][4:0];
        ALU_SLL:  opd = ops[0] << ops[1][4:0];
        ALU_SRA:  opd = sops[0] >>> ops[1][4:0];
        default:  opd = 32'hdeadbeef;
      endcase
    end else begin
      opd = 0;
    end
  end
endmodule
