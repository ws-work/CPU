`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/10/23 15:27:24
// Design Name:
// Module Name: aludec
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
`include "defines2.vh"

 module aludec(
	input wire[5:0] funct,
	input wire[7:0] aluop,
	output reg[7:0] alucontrol
    );
	always @(*) begin
		case (aluop)
            8'b00000010: alucontrol <= {2'b0,funct};//and,or,xor,nor,sll,srl,sra, add(overflow),sub, addu,subu,sltu,div

            8'b00001000: alucontrol <= 8'b00100000;//addi(overflow)
            8'b00001001: alucontrol <= 8'b00100001;//addiu
            8'b00101010: alucontrol <= 8'b00101010;//slti
            8'b00101011: alucontrol <= 8'b00101011;//sltiu

            `EXE_ANDI_OP: alucontrol <= 8'b00110100;//andi
            `EXE_ORI_OP : alucontrol <= 8'b00110101;//ori
            `EXE_XORI_OP: alucontrol <= 8'b00110111;//xori
            `EXE_LUI_OP : alucontrol <= `EXE_LUI_OP;//lui
            // 8'b00101101 : alucontrol <= 8'b101101;


			default :     alucontrol <= aluop;

		endcase

	end
endmodule
