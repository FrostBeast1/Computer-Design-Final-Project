module control_unit (clk, reset, g_i, z_i, ctrl_o, Q_o);
	// Conditional inputs from data path: g_i, z_i
	// g_i = {0 -> u < x}, {1 -> u >= x}
	// z_i = {0 -> i > 0}, {1 -> i == 0}
	input wire clk, reset, g_i, z_i;

	// Control signals to data path.
	// 0 - Step 1
	// 1 - Step 2
	// 2 - Step 3
	output wire [3:0] ctrl_o;
	output wire [1:0] Q_o;
	
	assign Q_o = state;
	
	reg [3:0] control;
	wire [1:0] state;
	
	// Sets the finish flag if z = 1
	assign ctrl_o = control;
	
	// State Machine
	control_state_register cu_sm(
		.clk_i(clk),
		.reset_i(reset),
		.z_i(z_i),
		.Q_o(state)
	);

	// Combinational Flag logic
	always @(state) begin
		control = 4'b0000;
		// Locks control unit output if z = 1
		case(state)
			// Step 1
			2'b00 : control <= 4'b0001;
			// Step 2
			2'b01 : control <= 4'b0010;
			// Step 3
			2'b10 : control <= 4'b0100;
			2'b11 : control <= 4'b1000;
			default: control <= 4'b0000;
		endcase
	end

endmodule