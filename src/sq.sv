`include "defs.svh"

module sq #(
  parameter SIZE = `SQ_SIZE,
  parameter P_WIDTH = 3,
  parameter C_WIDTH = 3
) (
  input clock, reset,
  store.sq store,
);
  typedef logic [3:0] mask_t;

  typedef enum logic [1:0] {
    EMPTY      = 3'b000,
    DISPATCHED = 3'b001,
    COMPLETED  = 3'b010,
    RETIRED    = 3'b011,
    LOADING    = 3'b100,
    LOADED     = 3'b101
  } state_t;

  typedef struct packed {
    state_t   state;
    addr_t    addr;
    xlen_t    data;
    xlen_t    mask;
    rob_idx_t rob_idx;
  } entry_t;

  entry_t [SIZE-1:0] data, data_next;

  typedef struct packed {
    sq_idx_t pending;
    sq_idx_t retire;
    sq_idx_t complete;
    sq_idx_t dispatch;
  } head_t;

  head_t head, head_next;

  typedef struct packed {
    bool pending;
    bool retire;
    bool complete;
    bool dispatch;
  } empty_t;

  empty_t empty, empty_next;

  always_comb begin
    data_next = data;
    head_next = head;
    empty_next = empty_next;

    if (empty_next.pending == FALSE) begin
      if (data_next[head_next.pending].state) begin
        if (store.accepted) begin
          data_next[head_next.pending] = 0;
          head_next.pending = (head_next.pending + 1) % SIZE;
          empty_next.dispatch = FALSE;
          if (head_next.pending == head_next.retire) begin
            empty_next.pending = TRUE;
          end
        end
      end else begin
        if (store.avail) begin
          store.valid = TRUE;
          store.addr = data_next[head_next.pending].addr;
          store.data = data_next[head_next.pending].data;
          data_next[head_next.pending].submit = TRUE;
        end
      end
    end

    for (int i = 0; i < retire.WIDTH; i++) begin
      if (
        retire.valid[i] &&
        retire.opt[i] == OPT_MEM &&
        retire.fun[i] == MEM_STORE
      ) begin
        head_next.retire = (head_next.retire + 1) % SIZE;
        empty_next.retire = FALSE;
        if (head_next.retire == head_next.complete) begin
          empty_next.complete = TRUE;
        end
      end
    end

    for (int i = 0; i < dispatch.WIDTH; i++) begin
      if (empty_next.dispatch == TRUE ||
        head_next.dispatch != head_next.pending) begin
      end
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
    end else begin
    end
  end
endmodule
