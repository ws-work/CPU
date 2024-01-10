`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/09 21:54:07
// Design Name: 
// Module Name: t
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


module t();
    reg a,b;
    reg [5:0] tm;
    initial begin 
        a = 1; b = 1;
        tm = 6'b011000;
        #10
        tm = tm |{a,b};
         
    end
endmodule
