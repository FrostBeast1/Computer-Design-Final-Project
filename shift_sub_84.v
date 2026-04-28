module shift_sub_84 #(parameter BUS_WIDTH = 4) (Dividend, Divisor, 
	Quotient, Remainder, Overflow, Clk, Reset);
	
	input Clk, Reset;
	input [BUS_WIDTH*2 - 1:0] Dividend;
	input [BUS_WIDTH - 1:0] Divisor;
	output reg [BUS_WIDTH - 1:0] Quotient, Remainder;
	output reg Overflow;
	
	reg [2:0] state, next_state;
	
   // Datapath registers
   reg [BUS_WIDTH - 1:0] u, v, x, y;
   reg [2:0] i;

   // Next versions of registers
	// Needed when reffering to itself i.e. i = i - 1
   reg [BUS_WIDTH - 1:0] next_u, next_v, next_x, next_y;
   reg [2:0] next_i;

   reg c, next_c;
   reg Finish, next_Finish;
	 
	wire Z, G;
	
	assign G = (u >= x);
   assign Z = (i == 3'b000);

	 
	// if Reset button is pressed change state to state 0
	// if Finish = 1, don't change state so next always block doesn't start
	always @(posedge Clk or negedge Reset) begin
		if (!Reset) begin
			state <= 3'b000;
			u <= 0; v <= 0; x <= 0; y <= 0;
         i <= 0;
         c <= 0;
         Finish <= 0;

		end else begin
			state <= next_state;
			u <= next_u;
         v <= next_v;
         x <= next_x;
         y <= next_y;
         i <= next_i;
         c <= next_c;
         Finish <= next_Finish;
		end
   end
	
	always @(state) begin
	
		next_state = state;
		next_u = u;
		next_v = v;
		next_x = x;
		next_y = y;
		next_i = i;
		next_c = c;
		next_Finish = Finish;
		
		case(state)
			// state 0
			3'b000 : begin
				{next_u, next_v} = Dividend;
				next_x = Divisor;
				next_Finish = 1'b0;
				next_state = 3'b001;
			end
			
			// state 1
			3'b001 : begin
				if (G) begin
					Overflow = 1;
					next_Finish = 1;
					next_state = 3'b101;
				end else begin
					Overflow = 0;
					next_state = 3'b010;
            end
			end
			
			// state 2
			3'b010 : begin
				next_y = 4'b0000;
				next_c = 1'b0;
				next_i = 3'b100;
				next_state = 3'b011;
			end
			
			// state 3
			3'b011 : begin
				next_c = u[3];
            next_u = {u[2:0], v[3]};
            next_v = {v[2:0], 1'b0};
            next_y = y << 1;
            next_i = i - 1;
				next_state = 3'b100;
			end
			
			// state 4
			3'b100 : begin
				if (c || G) begin
					next_y[0] = 1'b1;
					next_u = {c, u} + ~x + 1'b1; // u = cu - x
				end
				
				// if counter is not 0, return to state 3
				if (!Z) begin
					next_state = 3'b011;
				end else begin
					next_state = 3'b101;
				end
			end
			
			// state 5
			3'b101 : begin
				next_Finish = 1'b1;
				Quotient = y;
				next_state = 3'b101;
				
				// Stops nonsensical remainder from displaying when overflow
				if (Overflow)
					Remainder = 4'b0000;
				else	
					Remainder = u;
					
			end
			default: next_state = 3'b000;
		endcase
	end
	
	

endmodule