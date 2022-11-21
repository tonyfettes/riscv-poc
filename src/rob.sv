`include "dispatch.svh"
`include "complete.svh"
`include "rename.svh"
`include "retire.svh"
`include "rewind.svh"
`include "resolve.svh"
`include "except.svh"

module rob #(
  parameter SIZE = 32
) (
  input clock, reset,
  rename.rob rename,
  dispatch.rob dispatch,
  complete.rob complete,
  retire.rob retire,
  rewind.rob rewind,
  resolve.rob resolve,
  except.rob except
);
  typedef struct packed {
    bool valid;
    enum logic {
      ROB_EXC_BRC = 1'b0,
      ROB_EXC_EXC = 1'b1
    } ty;
    exc_t code;
  } rob_exc_t;

  typedef struct packed {
    bool            valid;
    bool            complete;
    opt_t           opt;
    fun_t           fun;
    sel_t     [1:0] sel;
    pc_t            pc;
    imm_t           imm;
    phy_reg_t [1:0] src;
    arc_reg_t       arc_dst;
    phy_reg_t       phy_dst;
    phy_reg_t       phy_dst_old;
    rob_exc_t       exc;
    rs_idx_t        rs_idx;
  } entry_t;

  entry_t [SIZE-1:0] data;
  entry_t [SIZE-1:0] data_next;

  typedef struct packed {
    rob_idx_t retire;
    rob_idx_t dispatch;
    rob_idx_t rename;
  } rob_head_t;

  rob_head_t head;
  rob_head_t head_next;

  typedef struct packed {
    bool retire;
    bool dispatch;
    bool rename;
  } rob_empty_t;

  rob_empty_t empty;
  rob_empty_t empty_next;

  rob_idx_t exc_count;

  always_comb begin
    data_next = data;
    head_next = head;
    empty_next = empty;

    exc_count = 0;

    for (int i = 0; i < SIZE; i++) begin
      if (data_next[i].exc.valid) begin
        exc_count = exc_count + 1;
      end
    end

    // Branch
    if (resolve.valid && !resolve.right) begin
      if (data_next[resolve.rob_idx].valid) begin
        data_next[resolve.rob_idx].exc.valid = TRUE;
        data_next[resolve.rob_idx].exc.ty = ROB_EXC_BRC;
      end
    end
    // Complete
    for (int i = 0; i < complete.WIDTH; i++) begin
      if (complete.valid[i]) begin
        if (data_next[complete.rob_idx[i]].valid) begin
          data_next[complete.rob_idx[i]].complete = TRUE;
          if (complete.exc_valid[i]) begin
            data_next[complete.rob_idx[i]].exc.valid = TRUE;
            data_next[complete.rob_idx[i]].exc.ty = ROB_EXC_EXC;
            data_next[complete.rob_idx[i]].exc.code = complete.exc[i];
          end
        end
      end
    end

    // Rewind
    rewind.valid = 0;
    for (int i = 0; i < rewind.WIDTH; i++) begin
      if (empty_next.dispatch == FALSE && exc_count > 0) begin
        rewind.valid[i] = 1'b1;
        rewind.arc_dst[i] = data_next[head_next.rename - 1].arc_dst;
        rewind.phy_dst[i] = data_next[head_next.rename - 1].phy_dst;
        rewind.phy_dst_old[i] =
          data_next[head_next.rename - 1].phy_dst_old;
        rewind.rs_idx[i] = data_next[head_next.rename - 1].rs_idx;

        data_next[head_next.rename - 1].valid = FALSE;

        head_next.rename = head_next.rename - 1;
        if (head_next.rename == head_next.dispatch) begin
          empty_next.dispatch = TRUE;
        end
      end else if (empty_next.retire == FALSE &&
                   (exc_count > 1 ||
                    data_next[head_next.dispatch - 1].exc.valid)) begin
        rewind.valid[i] = 1'b1;
        rewind.arc_dst[i] = data_next[head_next.dispatch - 1].arc_dst;
        rewind.phy_dst[i] = data_next[head_next.dispatch - 1].phy_dst;
        rewind.phy_dst_old[i] =
          data_next[head_next.dispatch - 1].phy_dst_old;
        rewind.rs_idx[i] = data_next[head_next.dispatch - 1].rs_idx;

        if (data_next[head_next.dispatch - 1].exc.valid) begin
          exc_count = exc_count - 1;
          data_next[head_next.dispatch - 1].exc.valid = FALSE;
        end
        data_next[head_next.dispatch - 1].valid = FALSE;

        head_next.dispatch = head_next.dispatch - 1;
        if (head_next.dispatch == head_next.retire) begin
          empty_next.retire = TRUE;
        end
      end
    end

    // Retire
    except.valid = FALSE;
    except.code = EXC_NO_ERROR;
    for (int i = 0; i < retire.WIDTH; i++) begin
      if (retire.avail[i] && empty_next.retire == FALSE) begin
        if (data_next[head_next.retire].exc.valid) begin
          // If it is at the oldest exception, ...
          if (head_next.dispatch == (head_next.retire + 1) % SIZE) begin
            // If rewind is done, ...
            if (data_next[head_next.retire].exc.ty == ROB_EXC_BRC) begin
              data_next[head_next].exc.valid = FALSE;
              exc_count = exc_count - 1;
            end else begin
              except.valid = TRUE;
              except.code = data_next[head_next].exc;
            end
          end
        end else if (data_next[head_next.retire].complete) begin
          retire.valid[i] = TRUE;
          retire.opt[i] = data_next[head_next.retire].opt;
          retire.fun[i] = data_next[head_next.retire].fun;
          retire.arc_dst[i] = data_next[head_next.retire].arc_dst;
          retire.phy_dst[i] = data_next[head_next.retire].phy_dst;
          retire.phy_dst_old[i] =
            data_next[head_next.retire].phy_dst_old;
          data_next[head_next.retire].valid = FALSE;
          head_next.retire = (head_next.retire + 1) % SIZE;
          if (head_next.retire == head_next.dispatch) begin
            empty_next.retire = TRUE;
          end
        end
      end
    end

    if (exc_count == 0) begin
      // Rename
      for (int i = 0; i < rename.WIDTH; i++) begin
        if (rename.valid[i] && empty_next.rename == FALSE) begin
          data_next[head_next.rename].valid = TRUE;
          data_next[head_next.rename].opt = rename.opt[i];
          data_next[head_next.rename].fun = rename.fun[i];
          data_next[head_next.rename].sel = rename.sel[i];
          data_next[head_next.rename].pc = rename.pc[i];
          data_next[head_next.rename].imm = rename.imm[i];
          data_next[head_next.rename].src = rename.src[i];
          data_next[head_next.rename].arc_dst = rename.arc_dst[i];
          data_next[head_next.rename].phy_dst = rename.phy_dst[i];
          data_next[head_next.rename].phy_dst_old =
            rename.phy_dst_old[i];
          head_next.rename = (head_next.rename + 1) % SIZE;
          if (head_next.rename == head_next.retire) begin
            empty_next.rename = TRUE;
          end
        end
      end
      // Dispatch
      dispatch.valid = 0;
      for (int d = 0; d < dispatch.WIDTH; d++) begin
        if (dispatch[d].avail && empty_next.dispatch == FALSE) begin
          dispatch.valid[d]   = TRUE;
          dispatch.opt[d]     = data_next[head_next.dispatch].opt;
          dispatch.fun[d]     = data_next[head_next.dispatch].fun;
          dispatch.sel[d]     = data_next[head_next.dispatch].sel;
          dispatch.pc[d]      = data_next[head_next.dispatch].pc;
          dispatch.imm[d]     = data_next[head_next.dispatch].imm;
          dispatch.src[d]     = data_next[head_next.dispatch].src;
          dispatch.dst[d]     = data_next[head_next.dispatch].phy_dst;
          dispatch.rob_idx[d] = head_next.dispatch;
          data_next[head_next.dispatch].rs_idx = dispatch.rs_idx[d];
          head_next.dispatch = (head_next.dispatch + 1) % SIZE;
          if (head_next.dispatch == head_next.rename) begin
            empty_next.dispatch = TRUE;
          end
        end
      end
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      data  <= `SD '0;
      head  <= `SD '0;
      empty <= `SD {TRUE, TRUE, TRUE};
    end else begin
      data  <= `SD data_next;
      head  <= `SD head_next;
      empty <= `SD empty_next;
    end
  end
endmodule
