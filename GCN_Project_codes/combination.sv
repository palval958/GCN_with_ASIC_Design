`include "combinational_FSM.sv"
`include "mux_combinational.sv"
`include "Matrix_FM_WM_ADJ_Memory.sv"
`include "row_adder.sv"
`include "counter_edge.sv"


module combination
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
    input logic [COO_BW - 1:0] coo_in [0:1],
    input logic start,
    input logic [DOT_PROD_WIDTH-1:0] fm_wm_row_data [0:WEIGHT_COLS-1],   // from transformation block
    input logic [COO_BW-1:0] read_row_arg, //FROM ARGMAX

    output logic [COO_BW - 1:0] edge_count,
    output logic done,
    output logic [DOT_PROD_WIDTH-1:0] adj_fm_wm_row [0:WEIGHT_COLS-1],  // to argmax block
    output logic [COO_BW-1:0] read_row_fw  //to transformation block

);
    logic enable_write_fm_wm_adj_prod;
    logic enable_edge_counter;
    logic read_fm_wm;
    logic read_fm_wm_adj;
    logic [COO_BW-1:0] read_row_mux1;
    logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_adder[0:WEIGHT_COLS-1];
    logic [COO_BW - 1:0] coo_in1 [0:1];
    logic  [COO_BW-1:0] read_row_fwa_muxi;
    logic  [COO_BW-1:0] read_row_fwa;
    assign coo_in1[0] = coo_in[0]-1'b1;
    assign coo_in1[1] = coo_in[1]-1'b1;
    

    combinational_FSM cf0(.clk(clk),
                          .reset(reset),
                          .edge_count(edge_count),
                          .start(start),
                          .enable_write_fm_wm_adj_prod(enable_write_fm_wm_adj_prod),
                          .enable_edge_counter(enable_edge_counter),
                          .read_fm_wm(read_fm_wm),
                          .read_fm_wm_adj(read_fm_wm_adj), 
                          .done(done));

    mux_combinational mc0(    //mux to send row number to transformation
    .select(read_fm_wm),
    .i0(coo_in1[0]),
    .i1(coo_in1[1]),
    .o(read_row_fw));   //output to combination.sv
    mux_combinational mc1(    //mux to send row number write and input for the mux which is attached to read
    .select(read_fm_wm_adj),
    .i0(coo_in1[0]),
    .i1(coo_in1[1]),
    .o(read_row_fwa_muxi));

    mux_combinational mc2(
    .select(done),
    .i0(read_row_fwa_muxi),
    .i1(read_row_arg),
    .o(read_row_fwa));   //read_row_for_memory);

    Matrix_FM_WM_ADJ_Memory mfwa0 (.clk(clk),
                                   .rst(reset),
                                   .write_row(read_row_fwa_muxi),
                                   .read_row(read_row_fwa),
                                   .wr_en(enable_write_fm_wm_adj_prod),
                                   .fm_wm_adj_row_in(fm_wm_adj_row_adder),  //adder output connected back to matrix
                                   .fm_wm_adj_out(adj_fm_wm_row));   //memory output given to either adder or to output for argmax block
    
    row_adder ra0(.fm_wm_in1(fm_wm_row_data),
                  .fm_wm_in2(adj_fm_wm_row),
                  .fm_wm_adj_row_out(fm_wm_adj_row_adder));

    counter_edge ce0(.reset(reset),
                     .enable_edge(enable_edge_counter),
                     .clk(clk),
                     .countin(edge_count),
                     .count(edge_count));

endmodule
