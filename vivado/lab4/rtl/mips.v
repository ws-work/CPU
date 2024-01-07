`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/11/07 10:58:03
// Design Name:
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire[3:0] memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM
    );

	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire [5:0] alucontrolE;
	wire stallE,flushE,stallM,flushM,stallW,flushW,equalD;
	wire [4:0] rtD;
	wire njumpD,jumpD,jrD,AnsSwE,AddSwE;

	controller c(
		clk,rst,
		//decode stage
		opD,functD,rtD,equalD,
		pcsrcD,branchD,njumpD,jumpD,jrD,

		//execute stage
		stallE,flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,
		alucontrolE,

		//mem stage
		memtoregM,regwriteM,AnsSwE,AddSwE,
		stallM,flushM,
		//write back stage
		memtoregW,regwriteW,
		stallW,flushW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		jrD,
		pcF,
		rtD,
		instrF,
		//decode stage
		pcsrcD,branchD,
		njumpD,jumpD,
		equalD,
		opD,functD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		flushE,stallE,
		//mem stage
		memtoregM,
		regwriteM,
		AnsSwE,AddSwE,
		aluoutM,writedataM,
		flushM,stallM,
		memwriteM,
		readdataM,
		//writeback stage
		memtoregW,
		regwriteW,
		flushW,stallW
	    );

endmodule
