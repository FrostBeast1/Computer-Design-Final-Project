// Connor LaFreniere
// Triggers on micro operation

module Dump #(
    parameter ADDRESS_WIDTH   = 5,
    parameter START_ADDRESS = 5'b11011,
    parameter MAX_ADDRESS = 5'b11111
)(
    input  wire Clk,

    // Triggers start dump - connected to micro_o[12]
    input  wire Op_Cmd,

    // Selected address to dump - connected to memory module
    output reg [ADDRESS_WIDTH-1:0] Dump_Address,

    // Control outputs
	 // High when dumping
    output reg Dump_Active,
	 // High when finished dumping
    output reg Dump_Done
);

    reg triggered;

	 // Initialize all registers
	 initial begin
        triggered   = 1'b0;
        Dump_Active = 1'b0;
        Dump_Address   = {ADDRESS_WIDTH{1'b0}};
        Dump_Done   = 1'b0;
    end

	always @(negedge Clk) begin
		// If not already triggered, trigger
		if (!triggered && Op_Cmd) begin
            triggered   <= 1'b1;
            Dump_Active <= 1'b1;
            Dump_Address   <= START_ADDRESS;
        end

		// Iterative loop until max address reached
		if (Dump_Active && !Dump_Done) begin
            if (Dump_Address == MAX_ADDRESS) begin
                Dump_Done <= 1'b1;
					 Dump_Active <= 1'b0;
            end else begin
                Dump_Address <= Dump_Address + 1'b1;
            end
        end
    end
endmodule