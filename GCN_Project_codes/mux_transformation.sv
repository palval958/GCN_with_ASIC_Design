module mux_transformation
  #(parameter ADDRESS = 12)(
    input logic select,
    input logic [ADDRESS-1:0] i0,
    input logic [ADDRESS-1:0] i1,

    output logic [ADDRESS-1:0] o
);
  always_comb begin
    case (select)
      0 : o = i0;
      1 : o = i1;
    endcase
  end

endmodule