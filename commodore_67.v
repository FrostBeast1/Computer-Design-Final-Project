module commodore_67 #(parameter BUS_WIDTH = 8) (AC, Z, Clk);
	
	input Clk;
	input [BUS_WIDTH - 1:0] AC;
	output [BUS_WIDTH - 1:0] Z;

// Load 	000
// Store	001
// Jump	010
// Jea	011
// Add	100
// Sub	101
// Div	110
// Dump	111



endmodule