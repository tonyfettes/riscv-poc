`include "issue.svh"
`include "branch.svh"
`include "execute.svh"

module fu(
  input clock, reset,
  issue.fu issue,
  branch.fu branch,
  execute.fu execute
);
  bool      [issue.WIDTH-1:0] alu_valid;
  xlen_t    [issue.WIDTH-1:0] [1:0] alu_ops;
  alu_fun_t [issue.WIDTH-1:0] alu_fun;
  xlen_t    [issue.WIDTH-1:0] alu_opd;
  alu fu_alu [issue.WIDTH-1:0] (
    .valid(alu_valid),
    .ops(alu_ops),
    .fun(alu_fun),
    .opd(alu_opd)
  );

  bool         brc_valid;
  xlen_t [1:0] brc_ops;
  brc_fun_t    brc_fun;
  bool         brc_taken;
  brc fu_brc (
    .valid(brc_valid),
    .ops(brc_ops),
    .fun(brc_fun),
    .taken(brc_taken)
  );
  assign execute.valid[0] = TRUE;

  bool         mul_valid;
  bool         mul_avail;
  bool         mul_done;
  xlen_t [1:0] mul_ops;
  logic  [1:0] mul_sgn;
  xlen_t [1:0] mul_opd;
  mul fu_mul (
    .clock(clock),
    .reset(reset),
    .start(mul_valid),
    .sign(mul_sgn),
    .ops(mul_ops),
    .product(mul_opd),
    .avail(mul_avail),
    .done(mul_done)
  );

  bool         lsq_valid;
  xlen_t [1:0] lsq_ops;
  xlen_t       lsq_opd;

  localparam MIN_WIDTH = execute.WIDTH < issue.WIDTH ? execute.WIDTH : issue.WIDTH;

  always_comb begin
    alu_valid = 0;
    alu_ops = 0;
    alu_fun = 0;
    brc_valid = 0;
    brc_ops = 0;
    brc_fun = 0;
    execute.valid = 0;
    execute.dst = 0;
    execute.opd = 0;
    branch.valid = 0;
    branch.taken = 0;
    for (int i = 0; i < MIN_WIDTH; i++) begin
      issue.avail[i] = execute.avail[i];
    end
    for (int i = MIN_WIDTH; i < issue.WIDTH; i++) begin
      issue.avail[i] = FALSE;
    end
    for (int i = MIN_WIDTH; i < execute.WIDTH; i++) begin
      execute.valid[i] = FALSE;
    end
    for (int i = 0; i < issue.WIDTH; i++) begin
      if (issue.valid[i] && !issue.opi[i]) begin
        execute.valid[i] = TRUE;
        alu_valid[i] = TRUE;
        alu_ops[i] = issue.ops[i];
        alu_fun[i] = issue.fun[i].alu;
        execute.dst[i] = issue.dst[i];
        execute.opd[i] = alu_opd[i];
      end
    end
    if (issue.valid[0] && issue.opi[0]) begin
      execute.valid[0] = TRUE;
      alu_valid[0] = TRUE;
      alu_ops[0][0] = issue.aux[0].brc;
      // TODO: sign-extend
      alu_ops[0][1] = issue.imm[0];
      alu_fun[0] = ALU_ADD;
      brc_valid = TRUE;
      brc_ops = issue.ops[0];
      brc_fun = issue.fun[0].alu;
      branch.valid = TRUE;
      branch.taken = brc_taken;
      execute.dst[0] = issue.dst[0];
      execute.opd[0] = issue.aux[0].brc + 4;
    end
    if (issue.valid[1] && issue.opi[1]) begin
      execute.valid[1] = TRUE;
      alu_valid[1] = FALSE;
    end
  end
endmodule
