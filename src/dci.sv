`include "defs.svh"

module dci (
  input bool   valid,
  input inst_t inst,
  output opt_t opt,
  output fun_t fun,
  output sel_t [1:0] sel,
  output imm_t imm,
  output arc_reg_t [1:0] src,
  output arc_reg_t dst,
  output exc_t exc
);
  typedef enum logic [3:0] {
    IMM_O = 4'h0,
    IMM_I = 4'h1,
    IMM_S = 4'h2,
    IMM_B = 4'h3,
    IMM_U = 4'h4,
    IMM_J = 4'h5
  } imm_sel_t;

  imm_sel_t imm_sel;
  always_comb begin
    opt = OPT_ALU;
    fun = ALU_ADD;
    imm = '0;
    src = '0;
    dst = '0;
    imm_sel = IMM_O;
    exc = EXC_NO_ERROR;

    if (valid) begin
      casez (inst)
        `RV32_LUI: begin
          sel[0] = SEL_OPS;
          sel[1] = SEL_AUX;
          imm_sel = IMM_U;
          // here although opa is RS1, it is just zero register (0)
          dst = inst.u.rd;
        end
        `RV32_AUIPC: begin
          sel[0] = SEL_AUX;
          sel[1] = SEL_AUX;
          imm_sel = IMM_U;
          dst = inst.u.rd;
        end
        `RV32_JAL: begin
          opt = OPT_BRC;
          fun.brc.ty = BRC_JUMP;
          sel[0] = SEL_AUX;
          sel[1] = SEL_AUX;
          imm_sel = IMM_J;
          dst    = inst.j.rd;
        end
        `RV32_JALR: begin
          opt = OPT_BRC;
          fun.brc.ty = BRC_JUMP;
          sel[0] = SEL_OPS;
          sel[1] = SEL_AUX;
          imm_sel = IMM_I;
          src[0] = inst.i.rs1;
          dst    = inst.i.rd;
        end
        `RV32_BEQ,
        `RV32_BNE,
        `RV32_BLT,
        `RV32_BGE,
        `RV32_BLTU,
        `RV32_BGEU: begin
          opt = OPT_BRC;
          fun.brc.ty = BRC_BRANCH;
          fun.brc.branch = inst.b.funct3;
          sel[0] = SEL_AUX;
          sel[1] = SEL_AUX;
          imm_sel = IMM_B;
          // special case for B-type instructions
          src[0] = inst.b.rs1;
          src[1] = inst.b.rs2;
        end
        `RV32_LB,
        `RV32_LH,
        `RV32_LW,
        `RV32_LBU,
        `RV32_LHU: begin
          opt = OPT_MEM;
          fun.mem.ty = MEM_LOAD;
          fun.mem.func = inst.i.funct3;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]  = inst.i.rs1;
          dst     = inst.i.rd;
        end
        `RV32_SB, `RV32_SH, `RV32_SW: begin
          opt          = OPT_MEM;
          fun.mem.ty   = MEM_STORE;
          fun.mem.func = inst.s.funct3;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_S;
          src[0]  = inst.s.rs1;
          // special case for S-type instructions
          src[1]  = inst.s.rs2;
        end
        `RV32_ADDI: begin
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]  = inst.i.rs1;
          dst     = inst.i.rd;
        end
        `RV32_SLTI: begin
          fun.alu = ALU_SLT;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]  = inst.i.rs1;
          dst     = inst.i.rd;
        end
        `RV32_SLTIU: begin
          fun.alu = ALU_SLTU;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]  = inst.i.rs1;
          dst     = inst.i.rd;
        end
        `RV32_ANDI: begin
          fun.alu = ALU_AND;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]  = inst.i.rs1;
          dst     = inst.i.rd;
        end
        `RV32_ORI: begin
          fun.alu = ALU_OR;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]  = inst.i.rs1;
          dst     = inst.i.rd;
        end
        `RV32_XORI: begin
          fun.alu = ALU_XOR;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]  = inst.i.rs1;
          dst     = inst.i.rd;
        end
        `RV32_SLLI: begin
          fun.alu = ALU_SLL;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]       = inst.i.rs1;
          dst         = inst.i.rd;
        end
        `RV32_SRLI: begin
          fun.alu = ALU_SRL;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]       = inst.i.rs1;
          dst         = inst.i.rd;
        end
        `RV32_SRAI: begin
          fun.alu = ALU_SRA;
          sel[1]  = SEL_AUX;
          imm_sel = IMM_I;
          src[0]       = inst.i.rs1;
          dst         = inst.i.rd;
        end
        `RV32_ADD: begin
          src[0] = inst.r.rs1;
          src[1] = inst.r.rs2;
          dst   = inst.r.rd;
        end
        `RV32_SUB: begin
          fun.alu = ALU_SUB;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_SLT: begin
          fun.alu = ALU_SLT;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_SLTU: begin
          fun.alu = ALU_SLTU;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_AND: begin
          fun.alu = ALU_AND;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_OR: begin
          fun.alu = ALU_OR;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_XOR: begin
          fun.alu = ALU_XOR;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_SLL: begin
          fun.alu = ALU_SLL;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_SRL: begin
          fun.alu = ALU_SRL;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_SRA: begin
          fun.alu = ALU_SRA;
          src[0] = inst.r.rs1;
          src[1] = inst.r.rs2;
          dst    = inst.r.rd;
        end
        `RV32_MUL: begin
          opt     = OPT_MUL;
          fun.mul = MUL_;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_MULH: begin
          opt     = OPT_MUL;
          fun.mul = MUL_H;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_MULHSU: begin
          opt     = OPT_MUL;
          fun.mul = MUL_HSU;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        `RV32_MULHU: begin
          opt     = OPT_MUL;
          fun.mul = MUL_HU;
          src[0]  = inst.r.rs1;
          src[1]  = inst.r.rs2;
          dst     = inst.r.rd;
        end
        // `RV32_CSRRW, `RV32_CSRRS, `RV32_CSRRC: begin
        //   csr_op = `TRUE;
        // end
        `WFI: begin
          exc = EXC_HALTED_ON_WFI;
        end
        default: exc = EXC_ILLEGAL_INST;
      endcase  // casez (inst)

      // process imm
      case (imm_sel)
        IMM_O: imm = 0;
        IMM_I: imm = `RV32_Iimm_extract(inst);
        IMM_S: imm = `RV32_Simm_extract(inst);
        IMM_B: imm = `RV32_Bimm_extract(inst);
        IMM_U: imm = `RV32_Uimm_extract(inst);
        IMM_J: imm = `RV32_Jimm_extract(inst);
      endcase
    end  // if (valid)
  end
endmodule
