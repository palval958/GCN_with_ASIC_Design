module Vector_Multiplier
#(parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS = 96)
(
    input [FEATURE_WIDTH-1 : 0] FEATURE_COL [0:FEATURE_COLS-1] ,
    input [WEIGHT_WIDTH-1 : 0] WEIGHT_ROW [0: WEIGHT_ROWS-1],
    output logic [DOT_PROD_WIDTH-1 : 0] PRODUCT
);
    reg [DOT_PROD_WIDTH-1 : 0] temp [0: FEATURE_COLS-1];
    reg [DOT_PROD_WIDTH-1 : 0] sum1 [0: 47];
    reg [DOT_PROD_WIDTH-1 : 0] sum2 [0: 23];
    reg [DOT_PROD_WIDTH-1 : 0] sum3 [0: 11];
    reg [DOT_PROD_WIDTH-1 : 0] sum4 [0: 5];
    reg [DOT_PROD_WIDTH-1 : 0] sum5 [0: 2];
    always_comb  begin 
        
        for (int i=0; i<96; i++) begin
            temp[i] = FEATURE_COL[i] * WEIGHT_ROW[i];
        end
        
        for (int j=0; j<48; j++) begin
            sum1[j] = temp[j] + temp[95-j];
        end

        for (int k=0; k<24; k++) begin
            sum2[k] = sum1[k] + sum1[47-k];
        end

        for (int l=0; l<12; l++) begin
            sum3[l] = sum2[l] + sum2[23-l];
        end

        for (int m=0; m<6; m++) begin
            sum4[m] = sum3[m] + sum3[11-m];
        end

        for (int n=0; n<3; n++) begin
            sum5[n] = sum4[n] + sum4[5-n];
        end

        PRODUCT = sum5[0] + sum5[1] + sum5[2];
    end

endmodule

