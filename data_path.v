module data_path #(parameter BUS_WIDTH = 4) (Divisor, Dividend, Ctrl_In, Clk, Data_Out, Quotient, Remainder);
	input wire [2*BUS_WIDTH - 1:0] Dividend;
   input wire [BUS_WIDTH - 1:0] Divisor;
	
	// Control signals from control unit:
	// 0 - Step 1
	// 1 - Step 2
	// 2 - Step 3
	input wire [3:0] Ctrl_In;
   input wire Clk;
	
	// Conditional output to control unit:
	// 0 - g_i = {0 -> u < x}, {1 -> u >= x}
	// 1 - z_i = {0 -> i > 0}, {1 -> i == 0}
    // 2 - Overflow flag (set if initial overflow occurs)
    // 3 - Finish flag (set once algorithm is finished)
	output wire [3:0] Data_Out;
   output wire [3:0] Quotient;
   output wire [3:0] Remainder;
	
	// Internal registers and flags per specification
	reg [BUS_WIDTH - 1:0] Y;       // y: n-bit quotient register
	reg C;                           // c: 1-bit register (carry/borrow)
   reg [BUS_WIDTH - 1:0] U;                           // u: n-bit operation register
   reg [BUS_WIDTH - 1:0] V;                           // v: n-bit operation register

    // $clog2 takes log base 2 of a number. 
    //In this case we see how many bits are needed to encode the bus_width.
	reg [$clog2(BUS_WIDTH)-1:0] Counter; // iteration counter
	wire Z_flag;                           // z: 1 when Counter == 0
	wire G_flag;                           // G: 1 when U >= X
   reg overflow;
   reg finish;
	
	// Z & G combinational assigments (we can read from these in the always block as well)
   assign G_flag = U < Divisor ? 1'b0 : 1'b1;
	assign Z_flag = Counter > 0 ? 1'b0 : 1'b1;
	
	assign Data_Out[0] = G_flag;
	assign Data_Out[1] = Z_flag;

   assign Data_Out[2] = overflow;
   assign Data_Out[3] = finish;

   // Performs a bitwise AND so that outputs remain at zero until operations are finished
   // Alternatively, you could comment out these bitwise ANDs to view the registers as they change (e.g. for debugging)
   assign Quotient = Y & {BUS_WIDTH{finish}};
   assign Remainder = U & {BUS_WIDTH{finish}};
	
	// Sequential logic
	always @(posedge Clk) begin
		
        case(Ctrl_In)
            4'b0001 : begin
                // Initialize operation registers with dividend
                {U, V} <= Dividend;

                // Other unconditional initializations
                Counter <= BUS_WIDTH;
                Y <= 0;
			   end
				4'b0010 : begin
					// Initialize based on g flag
                overflow <= G_flag ? 1'b1 : 1'b0;
                finish <= G_flag ? 1'b1 : 1'b0;
			   end
            4'b0100 : begin
					if(!finish) begin
						 // Logical Shift left of CUV (accumulator) and 
						 {C, U, V} <= {C, U, V} << 1;
						 Y <= Y << 1;
						 Counter <= Counter - 1;
					end
					else
						Counter <= 0;
					end
            4'b1000 : begin
					if(!finish) begin
						 Y[0] <= (C || G_flag) ? 1'b1 : Y[0];
						 U <= (C || G_flag) ? {C, U} - Divisor : U;
						 finish <= Z_flag || finish;
					end
            end
				default : begin
					finish <= Z_flag || finish;
				end
        endcase
    end

endmodule