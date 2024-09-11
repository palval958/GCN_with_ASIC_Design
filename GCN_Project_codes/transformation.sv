`include "Transformation_FSM.sv"
`include "mux_transformation.sv"
`include "Scratch_Pad.sv"
`include "Vector_Multiplier.sv"
`include "Matrix_FM_WM_Memory.sv"
`include "counter_feature.sv"
`include "counter_weight.sv"


module Transformation 
  #(parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS = 96,
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter NUM_OF_NODES = 6,			 
    parameter COO_NUM_OF_COLS = 6,			
    parameter COO_NUM_OF_ROWS = 2,			
    parameter COO_BW = $clog2(COO_NUM_OF_COLS))
(
  input logic clk,
  input logic reset,
  input logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1],
  input logic start,
  input logic [COUNTER_FEATURE_WIDTH-1 : 0] read_row,


  output logic [ADDRESS_WIDTH-1:0] read_address,
  output logic enable_read,
  output logic [DOT_PROD_WIDTH-1:0] fm_wm_row [0:WEIGHT_COLS-1],
  output logic done
);
    logic [COUNTER_WEIGHT_WIDTH-1 : 0] weight_count;
    logic [COUNTER_FEATURE_WIDTH-1 : 0] feature_count; 
    logic [WEIGHT_WIDTH-1 : 0] weight_scratch_pad [0:WEIGHT_ROWS-1];
    logic [DOT_PROD_WIDTH-1 :0] fm_wm_value;
    logic [COUNTER_FEATURE_WIDTH-1 : 0] read_row_fw;
    logic [COUNTER_FEATURE_WIDTH-1 : 0] read_row_afw;
    logic enable_write_fm_wm_prod;
    logic enable_write;
    logic enable_scratch_pad;
    logic enable_weight_counter;
    logic enable_feature_counter;
    logic read_feature_or_weight;
    logic [ADDRESS_WIDTH-1:0] address_feature;
    logic [ADDRESS_WIDTH-1:0] address_weight;

    Transformation_FSM tf0 ( .clk(clk),
                        .reset(reset),
                        .weight_count(weight_count),
                        .feature_count(feature_count),
                        .start(start),
                        .enable_write_fm_wm_prod(enable_write_fm_wm_prod),
                        .enable_read(enable_read),
                        .enable_write(enable_write),
                        .enable_scratch_pad(enable_scratch_pad),
                        .enable_weight_counter(enable_weight_counter),
                        .enable_feature_counter(enable_feature_counter),
                        .read_feature_or_weight(read_feature_or_weight),
                        .done(done));
    

    Scratch_Pad sp0( .clk(clk),
                     .reset(reset),
                     .write_enable(enable_scratch_pad),
                     .weight_col_in(data_in),
                     .weight_col_out(weight_scratch_pad));
    

    Vector_Multiplier vm0 (.FEATURE_COL(data_in) ,
                           .WEIGHT_ROW(weight_scratch_pad),
                           .PRODUCT(fm_wm_value));
    
    Matrix_FM_WM_Memory mfwm0 (.clk(clk),
                               .rst(reset),
                               .write_row(feature_count),
                               .write_col(weight_count), 
                               .read_row(read_row),
                               .wr_en(enable_write_fm_wm_prod),
                               .fm_wm_in(fm_wm_value),
                               .fm_wm_row_out(fm_wm_row));

    counter_feature cf0(.reset(reset),
                        .enable_feature(enable_feature_counter),
                        .clk(clk),
                        .countin(feature_count),
                        .count(feature_count));

    counter_weight cw0( .reset(reset),
                        .enable_weight(enable_weight_counter),
                        .clk(clk),
                        .countin(weight_count),
                        .count(weight_count));
    
    assign address_feature = 13'b0001000000000 + feature_count;
    assign address_weight = 13'b0000000000000 + weight_count;
    mux_transformation mt0( .select(read_feature_or_weight),
                            .i0(address_weight),
                            .i1(address_feature),
                            .o(read_address));
    

endmodule
