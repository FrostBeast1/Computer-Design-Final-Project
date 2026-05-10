// MUX for directing opcode/next address

module Micro_MUX#(
    parameter OP_WIDTH = 3,
    parameter ADDR_WIDTH = 4
) (
    sel_i, op_i, addr_i, addr_o
);

input wire sel_i;
input wire [OP_WIDTH-1:-0] op_i;
input wire [ADDR_WIDTH-1:0] addr_i;
output wire [ADDR_WIDTH-1:0] addr_o;

assign addr_o = sel_i ? {1'b1, op_i} : addr_i;

endmodule