`include "transformation.sv"
`include "combination.sv"
`include "argmax.sv"

module GCN
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
    parameter COO_BW = $clog2(COO_NUM_OF_COLS)	
)
(
  input logic clk,	// Clock
  input logic reset,	// Reset 
  input logic start,
  input logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1], //FM and WM Data //weightwidth leads to a maximum value a matrix number can take
  input logic [COO_BW - 1:0] coo_in [0:1], //row 0 and row 1 of the COO Stream and one edge at each time

  output logic [COO_BW - 1:0] coo_address, // The column of the COO Matrix 
  output logic [ADDRESS_WIDTH-1:0] read_address, // The Address to read the FM and WM Data
  output logic enable_read, // Enabling the Read of the FM and WM Data
  output logic done, // Done signal indicating that all the calculations have been completed
  output logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_answer [0:FEATURE_ROWS - 1] // The answer to the argmax and matrix multiplication , // The answer to the argmax and matrix multiplication 

); 


    
    logic [COUNTER_FEATURE_WIDTH-1:0] read_row_from_comb;
    logic trans_done;
    logic comb_done;
    logic [DOT_PROD_WIDTH-1 : 0] fm_wm_row_to_comb [0:WEIGHT_COLS-1];
    logic [DOT_PROD_WIDTH-1:0] fm_wm_row [0:WEIGHT_COLS-1];    
    logic [DOT_PROD_WIDTH-1:0] adj_fm_wm_row_to_argmax [0:WEIGHT_COLS-1];
    logic [COUNTER_FEATURE_WIDTH-1:0] read_row_arg;
    Transformation t0 (.clk(clk),       //from input
                  .reset(reset),        //from input
                  .data_in(data_in),    //from input
                  .start(start),      //from input
                  .read_row(read_row_from_comb),  //from_comb and declared
                  .read_address(read_address),     //read_address_from_input
                  .enable_read(enable_read),       //from output
                  .fm_wm_row(fm_wm_row_to_comb),          //to comb block declared
                  .done(trans_done));                 //to comb block declared
    
    combination c0(.clk(clk),         //from input
                   .reset(reset),     //from input
                   .coo_in(coo_in),   //from input
                   .start(trans_done),  //from trans declared
                   .fm_wm_row_data(fm_wm_row_to_comb),   // from transformation block declared
                   .read_row_arg(read_row_arg), //FROM ARGMAX declared
                   .edge_count(coo_address),   //coo_address to output should be referenced from output variables
                   .done(comb_done),           //comb_done declared to argmax block
                   .adj_fm_wm_row(adj_fm_wm_row_to_argmax),  // to argmax block DECLARED
                   .read_row_fw(read_row_from_comb)
		  	);  //to transformation block declared);
     ///testing
      ///testing
    argmax a0(.clk(clk),          // from input main module
              .reset(reset),      // from input of main module
              .start(comb_done),      //from comb declared
              .adj_fm_wm_row(adj_fm_wm_row_to_argmax),    // from comb decalred
              .done(done),                            // from output of main module
              .read_row_arg(read_row_arg),          //to comb block declared
              .max_addi_answer(max_addi_answer));  //from output of the main module



endmodule
