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
	output reg[5:0] alucontrol
    );
	always @(*) begin
		case (aluop)
            8'b00000010: alucontrol <= funct;//and,or,xor,nor,sll,srl,sra, add(overflow),sub, addu,subu,sltu,div

            8'b00001000: alucontrol <= 6'b100000;//addi(overflow)
            8'b00001001: alucontrol <= 6'b100001;//addiu
            8'b00101010: alucontrol <= 6'b101010;//slti
            8'b00101011: alucontrol <= 6'b101011;//sltiu

            `EXE_ANDI_OP: alucontrol <= 6'b110100;//andi
            `EXE_ORI_OP : alucontrol <= 6'b110101;//ori
            `EXE_XORI_OP: alucontrol <= 6'b110111;//xori
            `EXE_LUT_OP : alucontrol <= `LUI;//lui


			default :
//				6'b100000:alucontrol <= 6'b010; //add
//				6'b100010:alucontrol <= 6'b110; //sub
//				6'b100100:alucontrol <= 6'b000; //and
//				6'b100101:alucontrol <= 6'b001; //or
//				6'b101010:alucontrol <= 6'b111; //slt

				alucontrol <= 6'b000000;

		endcase

	end
endmodule
