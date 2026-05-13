// Microsequencer Control Unit
// Note that opcode "hardwiring" for address translation is handled inside
// the Micro_MUX.v file.

module Microseqencer #(
    parameter OP_WIDTH = 3,
    parameter ADDR_WIDTH = 4,
    parameter MICRO_WIDTH = 14
) (
    clk_i, op_i, micro_o, debug_o
);

input wire clk_i;
input wire [OP_WIDTH-1:0] op_i;
output [MICRO_WIDTH-1:0] micro_o;
output [ADDR_WIDTH-1+1:0] debug_o;

// Local Address register
reg [ADDR_WIDTH-1:0] next_addr;

// Interconnecting wires
wire [ADDR_WIDTH-1:0] MUX_to_reg;

// Wires to split Micro_Memory output
wire select;
wire [MICRO_WIDTH-2:0] micro_op;
wire [ADDR_WIDTH-1:0] mem_to_MUX;

assign debug_o = {select, MUX_to_reg};

// Sub-module Instantiations
Micro_MUX #(
    .OP_WIDTH(OP_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) micro_mux (
    .sel_i(select),
    .op_i(op_i),
    .addr_i(mem_to_MUX),
    .addr_o(MUX_to_reg)
);

// Memory output updates on negedge
Micro_Memory micro_mem (
    .clock(clk_i),
    .address(next_addr),
    .q({select, micro_o, mem_to_MUX})
);

// Next address register updates on positive edge
always @(posedge clk_i) begin
    next_addr <= MUX_to_reg;
end

endmodule