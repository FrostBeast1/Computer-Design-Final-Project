// Raven Schiavo
// Doesn't include main memory
// dmp/exit handled by control unit

module Data_Path #(
	parameter CONTROL_WIDTH = 11, // Doesn't include memory read or write
	parameter WORD_WIDTH = 8, 
	parameter ADDRESS_WIDTH = 5, 
	parameter OP_CODE_WIDTH = 3 
	)(Clk, Mem_IN, Mem_OUT, Addr_Sel, IR_Out, Control_Bus,
	//Testing only
	Z_Out,AC_test, DR_test, AR_test, PC_test, IR_test
	);
	// testing only
	output [WORD_WIDTH - 1 : 0] AC_test;
	output [WORD_WIDTH - 1 : 0] DR_test;
	output [ADDRESS_WIDTH - 1 : 0] AR_test;
	output [ADDRESS_WIDTH - 1 : 0] PC_test;
	output [OP_CODE_WIDTH - 1 : 0] IR_test;
	output Z_Out;
	
	// Testing only
	assign AC_test = AC;
	assign DR_test = DR;
	assign AR_test = AR;
	assign PC_test = PC;
	assign IR_test = IR;
	assign Z_Out = Z;
	
	input Clk;
	input [CONTROL_WIDTH - 1 : 0] Control_Bus;
	input [WORD_WIDTH - 1 : 0] Mem_OUT;
	// Mem_IN and Mem_OUT is from the perspective of the memory
	output [ADDRESS_WIDTH - 1 : 0] Addr_Sel;
	output [WORD_WIDTH - 1 : 0] Mem_IN;
	output [OP_CODE_WIDTH - 1 : 0] IR_Out;
	

	// Internal registers
	reg [WORD_WIDTH - 1 : 0] AC, DR; 
	reg [ADDRESS_WIDTH - 1 : 0] AR, PC;
	reg [OP_CODE_WIDTH - 1 : 0] IR;	
	// For Jeq
	reg Z;
	
	// Assigning buffers based on control signals
	// Exact layout of control signals bound to change
	wire [1 : 0] ALUSel;
	assign {MEMBus, ARld, PCld, PCInc, PCBus, DRld, DRBus, ALUSel, ACld, IRld} = Control_Bus;
	
	// Not WORD_WIDTH to accomadate more addresses in the future
	// Connects MEMBus, PCBus, and DRBus to Data_Bus
	wire [OP_CODE_WIDTH + ADDRESS_WIDTH - 1 : 0] Data_Bus;
	assign Data_Bus = MEMBus ? Mem_OUT : (PCBus ? PC : (DRBus ? DR : {(OP_CODE_WIDTH + ADDRESS_WIDTH){1'b0}}));
	
	// Add if ALUSel 10, subtract when 01, and pass through when 00.
	// 11 Can be set to multiplication or divide later
	wire [WORD_WIDTH - 1 : 0] ALU;
	assign ALU = ALUSel[1] ? (ALUSel[0] ? Data_Bus : AC + Data_Bus) : (ALUSel[0] ? AC - Data_Bus : Data_Bus);

	// assign outputs
	assign Mem_IN = AC;
	assign IR_Out = IR;
	assign Addr_Sel = AR;
	
	
	// May change to negedge if control unit is posedge
	always @(negedge Clk) begin
		// bus selection
		if (MEMBus) begin
		
			//Data_Bus = Mem_OUT;
			
			//fetch 2, add 1, sub 1
			if (DRld) DR <= Data_Bus;
			
			//load 1
			//ALUSel must be 00
			if (ACld) AC <= ALU;
				
		end else if (PCBus) begin
			
			// Connect PC to data bus with unused MSB being 0
			//Data_Bus = {{OP_CODE_WIDTH{1'b0}}, PC};
			
			//fetch 1
			if (ARld) AR <= Data_Bus;
				
		end else if (DRBus) begin
			
			//Data_Bus = DR;
			
			//fetch 3
			if (ARld) AR <= Data_Bus[ADDRESS_WIDTH - 1 : 0];
				
			//jump/jeq 1
			//if the instruction is jeq, Z must be high to load PC
			if (PCld && (IR == 3'b011) && Z) begin
				PC <= Data_Bus[ADDRESS_WIDTH - 1 : 0];
			end else if (PCld && (IR != 3'b011)) PC <= Data_Bus[ADDRESS_WIDTH - 1 : 0];
 			
			//add 2, sub 2
			//ALUSel must be 10 to add or 01 to subtract
			if (ACld) AC <= ALU;
			
			//fetch 3
			// Only Op-code bits
			if (IRld) IR <= Data_Bus[WORD_WIDTH - 1 : WORD_WIDTH - OP_CODE_WIDTH];
		end 
		
		// Z is updated ONLY when AC is loaded from a subtraction
      if (ACld && ALUSel == 2'b01)
         Z <= (ALU == {WORD_WIDTH{1'b0}});   // 1 if result is zero, else 0
				
		//fetch 2
		if (PCInc) PC <= PC + 1'b1;
			
	end
endmodule