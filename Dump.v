module Dump #(
    parameter ADDRESS_WIDTH   = 5,
    parameter LAST_INSTR_ADDR = 5'b01000,
    parameter MAX_ADDRESS     = 5'b11111
)(
    input  wire Clk,

	// Connected to micro_o[13] / Data_Path_Control[13] (MemDump)
	input  wire  Op_Cmd,

    // Address controller
    output reg  [ADDRESS_WIDTH-1:0]  Dump_Addr,

    // Control outputs
    output reg                       Dump_Active,      // HIGH when dump is running
    output reg                       Dump_Done         // HIGH when all addresses have been read
);

    reg triggered;

    //assign Mem_Read_Dump   = Dump_Active;
    //assign Mem_Enable_Dump = Dump_Active;

    always @(posedge Clk) begin
        //if (!triggered && (CPU_Mon == LAST_INSTR_ADDR)) begin
		  if (!triggered && Op_Cmd) begin
            triggered   <= 1'b1;
            Dump_Active <= 1'b1;
            Dump_Addr   <= {ADDRESS_WIDTH{1'b0}};
            Dump_Done   <= 1'b0;
        end

        if (Dump_Active && !Dump_Done) begin
            if (Dump_Addr == MAX_ADDRESS) begin
                Dump_Done <= 1'b1;
            end else begin
                Dump_Addr <= Dump_Addr + 1'b1;
            end
        end

    end
	 
    initial begin
        triggered   = 1'b0;
        Dump_Active = 1'b0;
        Dump_Addr   = {ADDRESS_WIDTH{1'b0}};
        Dump_Done   = 1'b0;
    end

endmodule
