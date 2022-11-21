`include "defs.svh"

module mul #(parameter XLEN = 32, parameter NUM_STAGE = 4) (
  input clock, reset,
  input start,
  input [1:0] sign,
  input xlen_t [1:0] ops,

  output [(2*XLEN)-1:0] product,
  input avail,
  output logic done
);
  logic [(2*XLEN)-1:0] candi_out, plier_out, candi_in, plier_in;
  logic [NUM_STAGE:0][2*XLEN-1:0] internal_candis, internal_pliers;
  logic [NUM_STAGE:0][2*XLEN-1:0] internal_products;
  logic [NUM_STAGE:0] internal_dones;

  assign candi_in = sign[0] ? {{XLEN{candi[XLEN-1]}}, ops[0]} : {{XLEN{1'b0}}, ops[0]};
  assign plier_in = sign[1] ? {{XLEN{plier[XLEN-1]}}, ops[1]} : {{XLEN{1'b0}}, ops[1]};

  assign internal_candis[0]   = candi_in;
  assign internal_pliers[0]  = plier_in;
  assign internal_products[0] = 'h0;
  assign internal_dones[0]    = start;

  assign done    = internal_dones[NUM_STAGE];
  assign product = internal_products[NUM_STAGE];

  genvar i;
  for (i = 0; i < NUM_STAGE; ++i) begin : mstage
    mult_stage #(.XLEN(XLEN), .NUM_STAGE(NUM_STAGE)) ms (
      .clock(clock),
      .reset(reset),
      .product_in(internal_products[i]),
      .plier_in(internal_pliers[i]),
      .candi_in(internal_candis[i]),
      .start(internal_dones[i]),
      .product_out(internal_products[i+1]),
      .plier_out(internal_pliers[i+1]),
      .candi_out(internal_candis[i+1]),
      .avail(avail),
      .done(internal_dones[i+1])
    );
  end
endmodule

module mult_stage #(parameter XLEN = 32, parameter NUM_STAGE = 4) (
  input clock, reset, start,
  input [(2*XLEN)-1:0] plier_in, candi_in,
  input [(2*XLEN)-1:0] product_in,

  input avail,
  output logic done,
  output logic [(2*XLEN)-1:0] plier_out, candi_out,
  output logic [(2*XLEN)-1:0] product_out
);

  parameter NUM_BITS = (2*XLEN)/NUM_STAGE;

  logic [(2*XLEN)-1:0] prod_in_reg, partial_prod, next_partial_product, partial_prod_unsigned;
  logic [(2*XLEN)-1:0] next_plier, next_candi;

  assign product_out = prod_in_reg + partial_prod;

  assign next_partial_product = plier_in[(NUM_BITS-1):0] * candi_in;

  assign next_plier = {{(NUM_BITS){1'b0}},plier_in[2*XLEN-1:(NUM_BITS)]};
  assign next_candi  = {candi_in[(2*XLEN-1-NUM_BITS):0],{(NUM_BITS){1'b0}}};

  //synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      prod_in_reg  <= `SD 0;
      partial_prod <= `SD 0;
      plier_out    <= `SD 0;
      candi_out    <= `SD 0;
    end else if (avail) begin
      prod_in_reg  <= `SD product_in;
      partial_prod <= `SD next_partial_product;
      plier_out    <= `SD next_plier;
      candi_out    <= `SD next_candi;
    end else begin
      prod_in_reg  <= `SD prod_in_reg;
      partial_prod <= `SD partial_product;
      plier_out    <= `SD plier;
      candi_out    <= `SD candi;
    end
  end

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if (reset) begin
      done <= `SD 1'b0;
    end else if (avail) begin
      done <= `SD start;
    end else begin
      done <= `SD done;
    end
  end
endmodule
