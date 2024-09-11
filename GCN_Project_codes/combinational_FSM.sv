module combinational_FSM 
  #(parameter COO_EDGES = 6,
    parameter COO_BW = $clog2(COO_EDGES))
(
  input logic clk,
  input logic reset,
  input logic [COO_BW-1:0] edge_count,
  input logic start,


  output logic enable_write_fm_wm_adj_prod,
  output logic enable_edge_counter,
  output logic read_fm_wm,
  output logic read_fm_wm_adj, 
  output logic done
);

  typedef enum logic [2:0] {
	START,
    EDGE1,
    WRITE_M1,
	EDGE2,
    WRITE_M2,
    INCREMENT_EDGE_COUNTER,
	DONE
  } state_t;

  state_t current_state,next_state;

  always_ff @(posedge clk or posedge reset)
    if (reset)
        current_state <= START;
    else 
        current_state <= next_state;

  always_comb begin
    case (current_state)
        START: begin
            enable_write_fm_wm_adj_prod = 1'b0;
            enable_edge_counter = 1'b0;
            read_fm_wm = 1'b0;
            read_fm_wm_adj = 1'b0;
            done = 1'b0;
            
            if (start) begin
                next_state = EDGE1;
            end
            else begin
                next_state = START;
            end
        end

        EDGE1: begin
            enable_write_fm_wm_adj_prod = 1'b0;
            enable_edge_counter = 1'b0;
            read_fm_wm = 1'b0;
            read_fm_wm_adj = 1'b1;
            done = 1'b0;
            
            next_state = WRITE_M1;

        end

        WRITE_M1: begin
            enable_write_fm_wm_adj_prod = 1'b1;
            enable_edge_counter = 1'b0;
            read_fm_wm = 1'b0;
            read_fm_wm_adj = 1'b1;
            done = 1'b0;
            
            next_state = EDGE2;

        end
        
        EDGE2: begin
            enable_write_fm_wm_adj_prod = 1'b0;
            enable_edge_counter = 1'b0;
            read_fm_wm = 1'b1;
            read_fm_wm_adj = 1'b0;
            done = 1'b0;

            next_state = WRITE_M2;
        end

        WRITE_M2: begin
            enable_write_fm_wm_adj_prod = 1'b1;
            enable_edge_counter = 1'b0;
            read_fm_wm = 1'b1;
            read_fm_wm_adj = 1'b0;
            done = 1'b0;

            next_state = INCREMENT_EDGE_COUNTER;
        end

        INCREMENT_EDGE_COUNTER: begin
            enable_write_fm_wm_adj_prod = 1'b0;
            enable_edge_counter = 1'b1;
            read_fm_wm = 1'b0;
            read_fm_wm_adj = 1'b0;
            done = 1'b0;
            
            if(edge_count == COO_EDGES -1) begin
                next_state = DONE;  
            end
            else begin
                next_state = EDGE1;
            end

        end

        DONE: begin
            enable_write_fm_wm_adj_prod = 1'b0;
            enable_edge_counter = 1'b0;
            read_fm_wm = 1'b0;
            read_fm_wm_adj = 1'b0;
            done = 1'b1;

            next_state = DONE;
        end

    endcase
  end

endmodule