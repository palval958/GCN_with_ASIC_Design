module argmax_fsm
#(parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS))
(
    input logic clk,
    input logic reset,
    input logic start,

    output logic [2:0] row_number,
    output logic enable_write_argmax,
    output logic done
);
typedef enum logic [2:0] {
	START,
    STATE1,
    STATE2,
    STATE3,
    STATE4,
    STATE5,
    STATE6,
    STATE7
  } state_t;

  state_t current_state, next_state;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      current_state <= START;
    else
      current_state <= next_state;

  always_comb begin
    case (current_state)
    
    START: begin
        row_number = 3'b000;
        enable_write_argmax = 1'b0;
        done = 1'b0;

        if (start) begin
            next_state = STATE1;
        end
        else begin
            next_state = START;
        end
    end

    STATE1: begin
        row_number = 3'b001;
        enable_write_argmax = 1'b1;
        done = 1'b0;

        next_state = STATE2;
    end

    STATE2: begin
        row_number = 3'b010;
        enable_write_argmax = 1'b1;
        done = 1'b0;

        next_state = STATE3;
    end

    STATE3: begin
        row_number = 3'b011;
        enable_write_argmax = 1'b1;
        done = 1'b0;

        next_state = STATE4;
    end

    STATE4: begin
        row_number = 3'b100;
        enable_write_argmax = 1'b1;
        done = 1'b0;

        next_state = STATE5;
    end

    STATE5: begin
        row_number = 3'b101;
        enable_write_argmax = 1'b1;
        done = 1'b0;

        next_state = STATE6;
    end

    STATE6: begin
        row_number = 3'b101;
        enable_write_argmax = 1'b1;
        done = 1'b0;

        next_state = STATE7;
    end

    STATE7: begin
        row_number = 3'b101;
        enable_write_argmax = 1'b0;
        done = 1'b1;

        next_state = STATE7;
    end

    endcase

  end

endmodule