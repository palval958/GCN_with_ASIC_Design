module row_adder
 #(parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter FEATURE_WIDTH = $clog2(FEATURE_ROWS)
)
(

    input logic [DOT_PROD_WIDTH - 1:0] fm_wm_in1  [0:WEIGHT_COLS-1],
    input logic [DOT_PROD_WIDTH - 1:0] fm_wm_in2  [0:WEIGHT_COLS-1],
    output logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_out  [0:WEIGHT_COLS-1]
);
  always_comb begin
    fm_wm_adj_row_out[0] <= fm_wm_in1 [0] + fm_wm_in2 [0];
    fm_wm_adj_row_out[1] <= fm_wm_in1 [1] + fm_wm_in2 [1];
    fm_wm_adj_row_out[2] <= fm_wm_in1 [2] + fm_wm_in2 [2];
  end
endmodule

