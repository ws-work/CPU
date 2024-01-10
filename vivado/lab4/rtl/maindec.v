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
	input wire [31:0] instr,

	output wire memtoreg,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire[7:0] aluop,
	output wire jal,jr,branchAl,
    output wire mem_en,
	output wire invalid,
	output wire cp0we,
	output wire cp0sw
    );
	reg[12:0] controls;
	reg[4:0] j_controls;
	reg[2:0] cp0_controls;
	wire has;
	assign {regwrite,regdst,alusrc,memtoreg,mem_en,aluop} = controls;
//              1/0     0       1      1/0  ,访存类alu
	assign {jump,jal,jr,branch,branchAl} = j_controls;
	assign {has,cp0we,cp0sw} = cp0_controls;


	//j_controls
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


	//controls
	always @(*) begin
		case (op)
			6'b000000:
				case(funct)
					`EXE_BREAK,`EXE_SYSCALL:  controls <= 13'b00000_00000010;//特权指令
					`EXE_MULT,`EXE_MULTU,`EXE_DIV,`EXE_DIVU: controls <= 13'b00000_00000010;
					`EXE_JR: controls <= 13'b00000_00000010;
					`EXE_MTHI,`EXE_MTLO: controls <= 13'b00000_00000010;
					default: controls <= 13'b11000_00000010;//R-TYRE
				endcase

			6'b001100:controls <= 13'b10100_01011001;//andi
            6'b001101:controls <= 13'b10100_01011010;//ori
            6'b001110:controls <= 13'b10100_01011011;//xori
            6'b001111:controls <= 13'b10100_01011100;//lui

            6'b001000:controls <= 13'b10100_00001000;//addi
            6'b001001:controls <= 13'b10100_00001001;//addiu
            6'b001010:controls <= 13'b10100_00101010;//slti
            6'b001011:controls <= 13'b10100_00101011;//sltiu

			`JAL: 	  controls <= 13'b10000_00000000;
			`REGIMM_INST: case(rt)
				`BLTZAL,`BGEZAL: controls <= 13'b10000_00000000;
				default: controls <= 13'b00000_00000000;
			endcase

            `LB:    controls <= {5'b10111,`EXE_LB_OP};
            `LBU:   controls <= {5'b10111,`EXE_LBU_OP};
            `LH:    controls <= {5'b10111,`EXE_LH_OP};
            `LHU:   controls <= {5'b10111,`EXE_LHU_OP};
            `LW:    controls <= {5'b10111,`EXE_LW_OP};
            `SW:    controls <= {5'b00101,`EXE_SW_OP};
            `SH:    controls <= {5'b00101,`EXE_SH_OP};
            `SB:    controls <= {5'b00101,`EXE_SB_OP};

			6'b010000:  if (instr[25:21]==5'b00000 && instr[10:3]==0)
							controls <= 13'b10000_00000000;//mfc0
						else controls<= 13'b00000_00000000;
			default:  controls <= 13'b00000_00000000;//other op like j type
		endcase
	end

	//cp0_controls
	always @(*)begin
		case(op)
			6'b000000:
				 case(funct)
					 `EXE_BREAK,`EXE_SYSCALL:	cp0_controls <= 3'b100;
					 default : 		cp0_controls <= 3'b000;
				 endcase
			6'b010000:
				if (instr == `EXE_ERET)
                    cp0_controls <= 3'b100;      //eret
                else if (instr[25:21]==5'b00100 && instr[10:3]==0)
                    cp0_controls <= 3'b010;      //mtc0
                else if (instr[25:21]==5'b00000 && instr[10:3]==0)
                    cp0_controls <= 3'b001;      //mfc0
                else
                    cp0_controls <= 3'b000;
			default:cp0_controls <= 3'b000;
		endcase
	end

	assign invalid = {j_controls,controls,cp0_controls} == 23'b0;

endmodule
