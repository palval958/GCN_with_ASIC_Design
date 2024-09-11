module counter_weight
#(parameter WEIGHT_COLS = 3,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS))
(
  input logic reset,
  input logic enable_weight,
  input logic clk,
  input logic [COUNTER_WEIGHT_WIDTH-1:0] countin,

  output logic [COUNTER_WEIGHT_WIDTH-1:0] count
);
 always_ff @(posedge reset or posedge clk)
    if (reset) begin
        count <= 0;
    end
    else if (enable_weight) begin
	if(count == WEIGHT_COLS-1) begin
	  count<=0;
	end
        else begin
        count <= countin +1;
    	end
     end
endmodule