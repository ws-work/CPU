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
	input wire[5:0] opD,functD,
	input wire [4:0] rtD,
	input wire[31:0] instrD,
	input wire equalD,
	output wire pcsrcD,branchD,njumpD,jumpD,jrD,invalidD,

	//execute stage
	input wire stallE,flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,
	output wire[7:0] alucontrolE,

	//mem stage
	output wire memtoregM,regwriteM,AnsSwE,AddSwE,
    input wire	stallM,flushM,
	output wire mem_enM,
	//write back stage
	output wire memtoregW,regwriteW,
	input wire stallW,flushW,
	output wire cp0weM,cp0swM

    );

	//decode stage
	wire[7:0] aluopD;
	wire memtoregD,alusrcD,
		regdstD,regwriteD,jalD,balD,mem_enD;
	wire cp0weD,cp0swD;
	wire[7:0] alucontrolD;

	//execute stage
	wire jalE,jrE,balE,mem_enE;
	wire cp0weE,cp0swE;


	maindec md(
		opD,
		rtD,
		functD,
		instrD,
		memtoregD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		aluopD,
		jalD,jrD,balD,
		mem_enD,
		invalidD,
		cp0weD,
		cp0swD
		);
	aludec ad(functD,aluopD,alucontrolD);

	assign pcsrcD = branchD & equalD;
	assign njumpD = jumpD | jalD | jrD;

	assign AddSwE = jalE | balE;
	assign AnsSwE =  AddSwE | jrE;

	//pipeline registers
	flopenrc #(19) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,alusrcD,regdstD,regwriteD,alucontrolD,jalD,jrD,balD,mem_enD,cp0weD,cp0swD},
		{memtoregE,alusrcE,regdstE,regwriteE,alucontrolE,jalE,jrE,balE,mem_enE,cp0weE,cp0swE}
		);
	flopenrc #(10) regM(
		clk,rst,~stallM,flushM,
		{memtoregE,regwriteE,mem_enE,cp0weE,cp0swE},
		{memtoregM,regwriteM,mem_enM,cp0weM,cp0swM}
		);
	flopenrc #(8) regW(
		clk,rst,~stallW,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
