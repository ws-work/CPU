`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/10/23 15:21:30
// Design Name:
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,rtD,equalD,
	output wire pcsrcD,branchD,njumpD,jumpD,jrD,

	//execute stage
	input wire stallE,flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,
	output wire[5:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,regwriteM,AnsSwE,AddSwE,
    input wire	stallM,flushM,
	//write back stage
	output wire memtoregW,regwriteW,
	input wire stallW,flushW

    );

	//decode stage
	wire[7:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD,jalD,balD;
	wire[5:0] alucontrolD;

	//execute stage
	wire memwriteE;
	wire jalE,jrE,balE;


	maindec md(
		opD,
		rtD,
		functD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		aluopD,
		jalD,jrD,balD
		);
	aludec ad(functD,aluopD,alucontrolD);

	assign pcsrcD = branchD & equalD;
	assign njumpD = jumpD | jalD | jrD;

	assign AddSwE = jalE | balE;
	assign AnsSwE =  AddSwE | jrE;

	//pipeline registers
	flopenrc #(14) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,jalD,jrD,balD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,jalE,jrE,balE}
		);
	flopenrc #(8) regM(
		clk,rst,~stallM,flushM,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
		);
	flopenrc #(8) regW(
		clk,rst,~stallW,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
