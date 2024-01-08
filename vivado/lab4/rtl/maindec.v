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
`include "defines.vh"
`include "defines2.vh"

module maindec(
	input wire[5:0] op,
	input wire[4:0] rt,
	input wire[5:0] funct,

	output wire memtoreg,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire[7:0] aluop,
	output wire jal,jr,branchAl
    );
	reg[14:0] controls;
	reg[4:0] j_controls;
	assign {regwrite,regdst,alusrc,memtoreg,aluop} = controls;
//              1/0     0       1      1/0  ,访存类alu
	assign {jump,jal,jr,branch,branchAl} = j_controls;

	always @(*) begin
		case(op)
			`BEQ,`BNE,`BGTZ,`BLEZ: 	j_controls <= 5'b00010;
			`REGIMM_INST:
				case(rt)
					`BGEZ,`BLTZ: 	j_controls <= 5'b00010;
					`BLTZAL,`BGEZAL:j_controls <= 5'b00011;
				endcase
			`J: 	j_controls <= 5'b10000;
			`JAL:	j_controls <= 5'b01000;
			`R_TYPE: case(funct)
				`JR:	 j_controls <= 5'b10100;
				`JALR:	 j_controls <= 5'b00100;
				default: j_controls <= 5'b00000;
			endcase

			default:j_controls <= 5'b00000;
		endcase
	end

	always @(*) begin
		case (op)

			6'b000000:controls <= 12'b1100_00000010;//R-TYRE

			6'b001100:controls <= 12'b1010_01011001;//andi
            6'b001101:controls <= 12'b1010_01011010;//ori
            6'b001110:controls <= 12'b1010_01011011;//xori
            6'b001111:controls <= 12'b1010_01011100;//lui

            6'b001000:controls <= 12'b1010_00001000;//addi
            6'b001001:controls <= 12'b1010_00001001;//addiu
            6'b001010:controls <= 12'b1010_00101010;//slti
            6'b001011:controls <= 12'b1010_00101011;//sltiu

			`JAL: 	  controls <= 12'b1000_00000000;
			`REGIMM_INST: case(rt)
				`BLTZAL,`BGEZAL: controls <= 12'b1000_00000000;
				default: controls <= 12'b0000_00000000;
			endcase

            `LB:    controls <= {4'b1011,`EXE_LB_OP};
            `LBU:   controls <= {4'b1011,`EXE_LBU_OP};
            `LH:    controls <= {4'b1011,`EXE_LH_OP};
            `LHU:   controls <= {4'b1011,`EXE_LHU_OP};
            `LW:    controls <= {4'b1011,`EXE_LW_OP};
            `SW:    controls <= {4'b0010,`EXE_SW_OP};
            `SH:    controls <= {4'b0010,`EXE_SH_OP};
            `SB:    controls <= {4'b0010,`EXE_SB_OP};


//			6'b100011:controls <= 9'b101001000;//LW
//			6'b101011:controls <= 9'b001010000;//SW
//			6'b000100:controls <= 9'b000100001;//BEQ
//			6'b001000:controls <= 9'b101000000;//ADDI

//			6'b000010:controls <= 9'b000000100;//J
			default:  controls <= 12'b000000_00000000;//other op like j type
		endcase
	end
endmodule
