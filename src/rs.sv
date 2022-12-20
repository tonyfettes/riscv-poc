`include "dispatch.svh"
`include "complete.svh"
`include "rewind.svh"
`include "issue.svh"

module rs #(
  parameter SIZE = 16
) (
  input clock, reset,
  dispatch.rs dispatch,
  complete.rs complete,
  issue.rs issue,
  rewind.rs rewind
);
  typedef struct packed {
    bool            valid;
    opt_t           opt;
    fun_t           fun;
    sel_t     [1:0] sel;
    aux_t           aux;
    imm_t           imm;
    phy_reg_t [1:0] src;
    phy_reg_t       dst;
    bool      [1:0] ready;
    rob_idx_t       rob_idx;
    lq_idx_t        lq_idx;
    sq_idx_t        sq_idx;
  } entry_t;

  entry_t [SIZE-1:0] data;
  entry_t [SIZE-1:0] data_next;

  bool [issue.WIDTH-1:0] avail;

  always_comb begin
    data_next = data;
    avail = issue.avail;
    // Rewind
    for (int i = 0; i < rewind.WIDTH; i++) begin
      if (rewind.valid[i]) begin
        data_next[rewind.rs_idx[i]] = 0;
      end
    end
    // Complete
    for (int c = 0; c < complete.WIDTH; c++) begin
      if (complete.valid[c]) begin
        for (int i = 0; i < SIZE; i++) begin
          for (int k = 0; k < 2; k++) begin
            if (data_next[i].src[k] == complete.dst[k]) begin
              data_next[i].ready[k] = TRUE;
            end
          end
        end
      end
    end
    // Issue
    for (int s = 0; s < issue.WIDTH; s++) begin
      for (int i = 0; i < SIZE; i++) begin
        if (data_next[i].ready[0] & data_next[i].ready[1]) begin
          if (avail[s]) begin
            if (data_next[i].opt[s] || data_next[i].opt == OPT_ALU) begin
              issue.valid[s] = TRUE;
              issue.opi[s] = data_next[i].opt[s];
              issue.fun[s] = data_next[i].fun;
              issue.sel[s] = data_next[i].sel;
              issue.aux[s] = data_next[i].aux;
              issue.imm[s] = data_next[i].imm;
              issue.src[s] = data_next[i].src;
              issue.dst[s] = data_next[i].dst;
              data_next[i] = 0;
              avail[s] = 0;
            end
          end
        end
      end
    end
    // Dispatch
    for (int d = 0; d < dispatch.WIDTH; d++) begin
      if (dispatch.valid[d]) begin
        for (int i = 0; i < SIZE; i++) begin
          if (data_next[i].valid == FALSE) begin
            dispatch.avail[i] = TRUE;
            data_next[i].valid = TRUE;
            data_next[i].opt = dispatch.opt[d];
            data_next[i].fun = dispatch.fun[d];
            data_next[i].sel = dispatch.sel[d];
            case (dispatch.opt[d])
              OPT_BRC:
                data_next[i].aux.brc = dispatch.pc[d];
              OPT_MEM:
                data_next[i].aux.mem = dispatch.lsq_idx[d];
              default:
                data_next[i].aux = 0;
            endcase
            data_next[i].imm = dispatch.imm[d];
            data_next[i].src = dispatch.src[d];
            data_next[i].dst = dispatch.dst[d];
            data_next[i].rob_idx = dispatch.rob_idx[d];
          end
        end
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
