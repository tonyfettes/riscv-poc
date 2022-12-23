`include "fetch.svh"

module ds_test;
  logic clock;
  logic reset;

  memory memory ();
  evict evict ();
  load load ();

  ds #(
    .SIZE(8),
    .WAY(2)
  ) dut (
    .clock(clock),
    .reset(reset),
    .memory(memory),
    .evict(evict),
    .load(load)
  );

  always #5 clock = ~clock;

  initial begin
    clock = 0;
    reset = TRUE;

    memory.ack = 0;
    memory.ans_blk = 0;
    memory.ans_tag = 0;

    load.qry = FALSE;
    load.qry_mem_idx = 0;
    load.qry_lq_idx = 0;

    @(negedge clock);
    reset = FASLE;

    @(posedge clock);
    @(posedge clock);
    assert (load.ack == FALSE);
    assert (load.hit == FALSE);
    assert (load.ans == FALSE);
    assert (memory.qry_cmd == MEM_CMD_NONE);
    assert (memory.qry_blk == 0);
    assert (memory.qry_idx == 0);
    assert (evict.valid == FALSE);
    assert (evict.idx == 0);
    assert (evict.blk == 0);

    @(negedge clock);
    load.qry = TRUE;
    load.qry_mem_idx = 2;
    load.qry_lq_idx = 3;

    @(posedge clock);
    assert (load.hit == FALSE);
    assert (load.hit_blk == 0);
    assert (load.ack == FALSE);
    assert (load.ack_head == 0);
    assert (load.ans == FALSE);
    assert (load.ans_head == 0);
    assert (load.ans_blk == 0);

    @(negedge clock);
    assert (memory.qry_cmd == MEM_CMD_LOAD);
    assert (memory.qry_blk == 0);
    assert (memory.qry_idx == 2);

    for (int i = 0; i < 2; i++) begin
      @(posedge clock);
      assert (load.hit == FALSE);
      assert (load.hit_blk == 0);
      assert (load.ack == FALSE);
      assert (load.ack_head == 0);
      assert (load.ans == FALSE);
      assert (load.ans_head == 0);
      assert (load.ans_blk == 0);
    end

    @(negedge clock);
    memory.ack = 1;
    load.qry = FALSE;
    load.qry_mem_idx = 0;
    load.qry_lq_idx = 0;

    @(posedge clock);
    assert (load.hit == FALSE);
    assert (load.ack == TRUE);
    assert (load.ack_head == 3);
    assert (load.ans == FALSE);

    @(negedge clock);
    memory.ack = 0;

    @(negedge clock);
    memory.ans_tag = 1;
    memory.ans_blk = 64'hdeadbeefcc00ffee;

    @(posedge clock);
    assert (load.ans == TRUE);
    assert (load.ans_head == 0);
    assert (load.ans_blk == 64'hdeadbeefcc00ffee);

    @(negedge clock);
    memory.ans_tag = 0;

    @(negedge clock);
    load.qry = TRUE;
    load.qry_mem_idx = 2;
    load.qry_lq_idx = 4;

    @(posedge clock);
    assert (load.hit == TRUE);
    assert (load.hit_blk == 64'hdeadbeefcc00ffee);
    assert (load.ack == FALSE);
    assert (load.ans == FALSE);

    @(negedge clock);
    load.qry = FALSE;

    $finish;
  end
endmodule
