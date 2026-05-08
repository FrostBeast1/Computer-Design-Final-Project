// Main memory: 32 addressable spaces, 8 bits each
// Mem_IN and Mem_OUT from perspective of memory

module Main_Memory #(
	parameter WORD_WIDTH = 8,
	parameter ADDRESS_WIDTH = 5,
	parameter MEM_DEPTH = 32
	)(Clk, Address, Mem_IN, Mem_OUT, Mem_Read, Mem_Write, Mem_Enable);
	
	input Clk;
	input [ADDRESS_WIDTH - 1 : 0] Address;
	input [WORD_WIDTH - 1 : 0] Mem_IN;
	input Mem_Read;
	input Mem_Write;
	input Mem_Enable;
	output [WORD_WIDTH - 1 : 0] Mem_OUT;
	
	// Internal memory array
	reg [WORD_WIDTH - 1 : 0] memory [0 : MEM_DEPTH - 1];
	
	// Internal read buffer
	reg [WORD_WIDTH - 1 : 0] read_buffer;
	
	// Synchronous write
	always @(posedge Clk) begin
		if (Mem_Write)
			memory[Address] <= Mem_IN;
	end
	
	// Asynchronous read into buffer
	always @(*) begin
		if (Mem_Read)
			read_buffer = memory[Address];
		else
			read_buffer = {WORD_WIDTH{1'bz}};
	end
	
	// Tri-state output control
	assign Mem_OUT = Mem_Enable ? read_buffer : {WORD_WIDTH{1'bz}};
	
endmodule