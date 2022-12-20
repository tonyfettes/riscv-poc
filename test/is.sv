`include "fetch.svh"

module is_test;
  logic clock;
  logic reset;

  fetch #(.WIDTH(3)) fetch;
  memory memory;
  evict evict;

  localparam SIZE = 8;
  localparam BANK = 2;

  is #(
    .SIZE(8),
    .BANK(2)
  ) dut (
    .clock(clock),
    .reset(reset),
    .fetch(fetch),
    .memory(memory),
    .evict(evict)
  );

  always #5 clock = ~clock;

  initial begin
    clock = 0;
    reset = TRUE;

    fetch.enable = FALSE;
    fetch.pc = 0;

    memory.ack = 0;
    memory.ans_blk = 0;
    memory.ans_tag = 0;

    @(negedge clock);
    reset = FALSE;

    @(negedge clock);
    fetch.enable = TRUE;
    fetch.pc = 0;

    // I-cache should keep memory query before memory can response.
    for (int i = 0; i < 2; i++) begin
      @(posedge clock);
      assert memory.qry_cmd == MEM_CMD_LOAD;
      assert memory.qry_blk == 0;
      assert memory.qry_idx == 0;
      for (int j = 0; j < fetch.WIDTH; j++) begin
        assert fetch.data[i] == 0;
        assert fetch.valid[i] == FALSE;
      end
    end

    memory.ack = 1;

    for (int i = 0; i < 2; i++) begin
      @(posedge clock);
      assert memory.qry_cmd == MEM_CMD_NONE;
      assert memory.qry_blk == 0;
      assert memory.qry_idx == 0;
      for (int j = 0; j < fetch.WIDTH; j++) begin
        assert fetch.data[i] == 0;
        assert fetch.valid[i] == FALSE;
      end
    end

    @(negedge clock);
    memory.ans_blk = 64'hdeadbeefcc00ffee;
    memory.ans_tag = 1;

    @(posedge clock);
    assert fetch.valid[0];
    assert fetch.data[0] == 32'hdeadbeef;
    assert fetch.valid[1];
    assert fetch.data[1] == 32'hcc00ffee;
    assert fetch.valid[2] == FALSE;
    assert fetch.data[2] = 0;

    @(negedge clock);
    memory.ans_blk = 32'h12345678ffffffff;
    memory.ans_tag = 2;

    @(posedge clock);
    assert fetch.valid[2] == TRUE;
    assert fetch.data[2] == 32'h12345678;

    @(negedge clock);
    fetch.pc = 4;

    @(posedge clock);
    assert fetch.valid[0] && fetch.data[0] == 32'hcc00ffee;
    assert fetch.valid[1] && fetch.data[1] == 32'h12345678;
    assert fetch.valid[2] && fetch.data[2] == 32'hffffffff;
  end
endmodule
