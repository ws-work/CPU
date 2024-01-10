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
	output wire[31:0] pcconvertF,
	input wire[31:0] instrF,
	output wire[3:0] memwriteM,
	output wire[31:0] dataadr,writedataM,
	input wire[31:0] readdataM,
	output wire [31:0] pcW,resultW,
    output wire [4:0] writeregW,
    output wire regwriteW,
	output wire mem_enM
    );

	wire [31:0] pcF;
	wire [5:0] opD,functD;
	wire [31:0] instrD;
	wire invalidD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM;
	wire [7:0] alucontrolE;
	wire stallE,flushE,stallM,flushM,stallW,flushW,equalD;
	wire [31:0] aluoutM;
	wire [4:0] rtD;
	wire njumpD,jumpD,jrD,AnsSwE,AddSwE;
	wire cp0weM,cp0swM;

	mmu mmu0(
	.inst_vaddr(pcF),
	.inst_paddr(pcconvertF),
	.data_vaddr(aluoutM),
	.data_paddr(dataadr),
	.no_dcache(nocache)
	);


	controller c(
		clk,rst,
		//decode stage
		opD,functD,rtD,
		instrD,
		equalD,
		pcsrcD,branchD,njumpD,jumpD,jrD,invalidD,

		//execute stage
		stallE,flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,
		alucontrolE,

		//mem stage
		memtoregM,regwriteM,AnsSwE,AddSwE,
		stallM,flushM,
		mem_enM,
		//write back stage
		memtoregW,regwriteW,
		stallW,flushW,
		cp0weM,cp0swM
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
		invalidD,
		instrD,
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
		cp0weM,cp0swM,
		//writeback stage
		memtoregW,
		regwriteW,
		flushW,stallW,
		pcW,resultW,//
        writeregW//
	    );

endmodule
