`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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

module maindec(
	input wire[5:0] op,

	output wire memtoreg,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire[7:0] aluop
    );
	reg[14:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,aluop} = controls;
	always @(*) begin
		case (op)
		
			6'b000000:controls <= 15'b1100000_00000010;//R-TYRE
			
			6'b001100:controls <= 15'b1010000_01011001;//andi
            6'b001101:controls <= 15'b1010000_01011010;//ori
            6'b001110:controls <= 15'b1010000_01011011;//xori
            6'b001111:controls <= 15'b1010000_01011100;//lui
            
            6'b001000:controls <= 15'b1010000_00001000;//addi
            6'b001001:controls <= 15'b1010000_00001001;//addiu
            6'b001010:controls <= 15'b1010000_00001010;//slti
            6'b001011:controls <= 15'b1010000_00001011;//sltiu
            
            
            
            

			
//			6'b100011:controls <= 9'b101001000;//LW
//			6'b101011:controls <= 9'b001010000;//SW
//			6'b000100:controls <= 9'b000100001;//BEQ
//			6'b001000:controls <= 9'b101000000;//ADDI
			
//			6'b000010:controls <= 9'b000000100;//J
			default:  controls <= 15'b0000000_00000000;//illegal op
		endcase
	end
endmodule
