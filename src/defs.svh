`ifndef DEFS_SVH
`define DEFS_SVH

`include "isa.svh"

`define SD #1

typedef enum logic {
  FALSE = 1'b0,
  TRUE = 1'b1
} bool;

`define IDX_LEN(NUM) int'($ceil($clog2(NUM)))

`define ROB_SIZE 32
`define ROB_IDX_LEN `IDX_LEN(`ROB_SIZE)
typedef logic [`ROB_IDX_LEN-1:0] rob_idx_t;

`define RS_SIZE 16
`define RS_IDX_LEN `IDX_LEN(`RS_SIZE)
typedef logic [`RS_IDX_LEN-1:0] rs_idx_t;

`define RF_SIZE `ROB_SIZE + 32
`define RF_IDX_LEN `IDX_LEN(`RF_SIZE)
typedef logic [`RF_IDX_LEN-1:0] phy_reg_t;

typedef logic [`IDX_LEN(32)-1:0] arc_reg_t;

`define LQ_SIZE 8
`define SQ_SIZE 8
`define LQ_IDX_LEN `IDX_LEN(`LQ_SIZE)
`define SQ_IDX_LEN `IDX_LEN(`SQ_SIZE)
typedef logic [`LQ_IDX_LEN-1:0] lq_idx_t;
typedef logic [`SQ_IDX_LEN-1:0] sq_idx_t;
typedef struct packed {
  lq_idx_t lq;
  sq_idx_t sq;
} lsq_idx_t;

typedef struct packed {
  enum logic {
    MEM_LOAD = 1'b0,
    MEM_STORE = 1'b1
  } ty;
  union packed {
    enum logic [2:0] {
      MEM_LB  = 3'b000,
      MEM_LH  = 3'b001,
      MEM_LW  = 3'b010,
      MEM_LBU = 3'b100,
      MEM_LHU = 3'b101
    } load;
    enum logic [2:0] {
      MEM_SB = 3'b000,
      MEM_SH = 3'b001,
      MEM_SW = 3'b010
    } store;
  } func;
} mem_fun_t;

typedef enum logic [3:0] {
	ALU_ADD  = 4'h0,
	ALU_SUB  = 4'h1,
	ALU_SLT  = 4'h2,
	ALU_SLTU = 4'h3,
	ALU_AND  = 4'h4,
	ALU_OR   = 4'h5,
	ALU_XOR  = 4'h6,
	ALU_SLL  = 4'h7,
	ALU_SRL  = 4'h8,
	ALU_SRA  = 4'h9
} alu_fun_t;

typedef enum logic [3:0] {
	MUL_     = 4'h1,
	MUL_H    = 4'h2,
	MUL_HSU  = 4'h3,
	MUL_HU   = 4'h4
} mul_fun_t;

typedef struct packed {
  enum logic {
    BRC_BRANCH = 1'b0,
    BRC_JUMP = 1'b1
  } ty;
  enum logic [2:0] {
    BRC_BEQ  = 3'b000,
    BRC_BNE  = 3'b001,
    BRC_BLT  = 3'b100,
    BRC_BGE  = 3'b101,
    BRC_BLTU = 3'b110,
    BRC_BGEU = 3'b111
  } branch;
} brc_fun_t;

typedef union packed {
  mem_fun_t mem;
  alu_fun_t alu;
  mul_fun_t mul;
  brc_fun_t brc;
} fun_t;

typedef union packed {
  pc_t brc;
  lsq_idx_t mem;
} aux_t;

typedef enum logic [2:0] {
  OPT_ALU = 3'b000,
  OPT_MEM = 3'b100,
  OPT_MUL = 3'b010,
  OPT_BRC = 3'b001
} opt_t;

typedef enum logic {
  SEL_OPS = 1'b0,
  SEL_AUX = 1'b1
} sel_t;
typedef logic [19:0] imm_t;

typedef enum logic [3:0] {
	EXC_INST_ADDR_MISALIGN  = 4'h0,
	EXC_INST_ACCESS_FAULT   = 4'h1,
	EXC_ILLEGAL_INST        = 4'h2,
	EXC_BREAKPOINT          = 4'h3,
	EXC_LOAD_ADDR_MISALIGN  = 4'h4,
	EXC_LOAD_ACCESS_FAULT   = 4'h5,
	EXC_STORE_ADDR_MISALIGN = 4'h6,
	EXC_STORE_ACCESS_FAULT  = 4'h7,
	EXC_ECALL_U_MODE        = 4'h8,
	EXC_ECALL_S_MODE        = 4'h9,
	EXC_NO_ERROR            = 4'ha, //a reserved code that we modified for our purpose
	EXC_ECALL_M_MODE        = 4'hb,
	EXC_INST_PAGE_FAULT     = 4'hc,
	EXC_LOAD_PAGE_FAULT     = 4'hd,
	EXC_HALTED_ON_WFI       = 4'he, //another reserved code that we used
	EXC_STORE_PAGE_FAULT    = 4'hf
} exc_t;

typedef struct packed {
  enum logic {
    CF_BRC = 1'b0,
    CF_EXC = 1'b1
  } ty;
  exc_t code;
} cf_t;

typedef struct packed {
  bool valid;
  pc_t pc;
} opc_t;

`endif // DEFS_SVH
