module mshr #(
  parameter SIZE = 16
) (
  input clock, reset,
);
  typedef struct packed {
    bool      valid;
    addr_t    addr;
    mem_typ_t typ;
    union packed {
      lq_idx_t load;
      sq_idx_t store;
    } lsq_idx;
  } entry_t;

  entry_t [SIZE-1:0] data, data_next;
endmodule
