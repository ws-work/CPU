`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/04 23:14:28
// Design Name: 
// Module Name: test_si
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_si(    );
reg clk;
reg [31:0] x,y;
wire a,b; 
assign a = $signed(x)>$signed(y)?1:0;
assign b = x>y?1:0;

initial begin
x = 32'b11111111_11111111_11111111_11111111;
y = 32'b00000000_11111111_11111111_11111111;
end


endmodule
