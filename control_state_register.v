module control_state_register(clk_i, reset_i, z_i, Q_o);
    input wire clk_i, reset_i, z_i;
    output wire [1:0] Q_o;

    reg [1:0] state;
    reg [1:0] next_state;

    assign Q_o = state;

    // Next-state combinational logic.
    always @(state, z_i) begin
        case(state)
            2'b00: next_state <= 2'b01;
            2'b01: next_state <= 2'b10;
				2'b10: next_state <= 2'b11;
				2'b11: begin
					next_state <= z_i ? 2'b11 : 2'b10;
				end
				default: next_state <= 2'b00;
        endcase
	 end

    // State register block
    always @(posedge clk_i, negedge reset_i) begin
        if (!reset_i) begin
		  // Start signal -> go to step one
            state <= 2'b00;
        end
        else begin
		  // Assign next state to current state
            state <= next_state;
        end
    end
endmodule