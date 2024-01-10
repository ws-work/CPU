`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/01/09 21:11:10
// Design Name:
// Module Name: addr_except
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

`include "defines.vh"
module addr_except(
    input [31:0] addrs,
    input [7:0] alucontrolM,
    output reg adelM,
    output reg adesM
    );

    always @(*) begin
        adelM <= 1'b0;
        case (alucontrolM)
            `EXE_LH_OP: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 )
                adelM <= 1'b1;
            `EXE_LHU_OP: if ( addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 )
                adelM <= 1'b1;
            `EXE_LW_OP: if ( addrs[1:0] != 2'b00 )
                adelM <= 1'b1;
        endcase
    end
    always @(*) begin
        adesM <= 1'b0;
        case (alucontrolM)
            `EXE_SH_OP: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 )
                adesM <= 1'b1;
            `EXE_SW_OP: if ( addrs[1:0] != 2'b00 )
                adesM <= 1'b1;
        endcase
    end
endmodule
