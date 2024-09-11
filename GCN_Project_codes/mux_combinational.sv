//mux_argmax is same as mux_combinational

module mux_combinational
  #(parameter COO_EDGES = 6,
    parameter COO_BW = $clog2(COO_EDGES))(
    input logic select,
    input logic [COO_BW-1:0] i0,
    input logic [COO_BW-1:0] i1,

    output logic [COO_BW-1:0] o
);
  always_comb begin 
    case ( select )
      0 : o = i0;
      1 : o = i1;
    endcase
  end

endmodule