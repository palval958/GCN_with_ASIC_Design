module counter_edge
#(parameter COO_EDGES = 6,
    parameter COO_BW = $clog2(COO_EDGES))
(
  input logic reset,
  input logic enable_edge,
  input logic clk,
  input logic [COO_BW-1:0] countin,

  output logic [COO_BW-1:0]count
);
 always_ff @(posedge reset or posedge clk)
    if (reset) begin
        count <= 0;
    end
    else if (enable_edge) begin
	if(count == COO_EDGES-1) begin
	  count<=0;
	end
        else begin
        count <= countin +1;
    	end
     end
endmodule
