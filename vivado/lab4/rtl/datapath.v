`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/11/02 15:12:22
// Design Name:
// Module Name: datapath
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


module datapath(
    input wire clk,rst,
    input wire jrD,      //
    output wire[31:0] pcF,
    output wire [4:0] rtD, //
    input wire[31:0] instrF,

    input wire pcsrcD,branchD,
    input wire njumpD,jumpD,
    output wire equalD,
    output wire[5:0] opD,functD,

    input wire memtoregE,
    input wire alusrcE,regdstE,
    input wire regwriteE,
    input wire[5:0] alucontrolE,
    output wire flushE,stallE,

    input wire memtoregM,
    input wire regwriteM,
    input wire AnsSwE,AddSwE, //
    output wire[31:0] aluoutM,writedataM,
    output wire flushM,stallM,
	output wire[3:0] memwriteM,
    input wire[31:0] readdataM,

    input wire memtoregW,
    input wire regwriteW,
    output wire flushW,stallW
);

    //fetch stage
    wire stallF;
    //FD
    wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,jumpInstD;
    //decode stage
    wire [31:0] pcplus4D,pcplus8D,instrD;
    wire forwardaD,forwardbD,jrb_l_astall,jrb_l_bstall;
    wire [4:0] rsD,rtD,rdD,saD;
    wire flushD,stallD;
    wire [31:0] signimmD,signimmshD;
    wire [31:0] srcaD,srca2D,srcbD,srcb2D;
    //execute stage
    wire [1:0] forwardaE,forwardbE;
    wire [4:0] rsE,rtE,rdE,saE;
    wire [4:0] writeregE,writereg2E;
    wire [31:0] signimmE;
    wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
    wire [31:0] aluoutE,aluout2E;
    wire [31:0] pcplus8E;
    //mem stage
    wire [4:0] writeregM;
	wire [5:0] alucontrolM;
    //writeback stage
    wire [4:0] writeregW;
    wire [31:0] aluoutW,readdataW,resultW;
    wire divstallE;
    wire overflowE,zeroE;
    wire [63:0] aluoutE_64;
    wire [31:0] hi_o;
    wire [31:0] lo_o;
    wire hilo_ena;
    wire div_running;
	wire [5:0] alucontrolW;
	wire [31:0] readdata2W;

    //hazard detection
    hazard h(
    stallF,flushF,
	//decode stage
	rsD,rtD,
	branchD,jumpD,jrD,
	forwardaD,forwardbD,
    jrb_l_astall,jrb_l_bstall,
	stallD,flushD,
	//execute stage
	 rsE,rtE,
	writeregE,
	regwriteE,
	memtoregE,
	div_running,
	forwardaE,forwardbE,
	stallE,flushE,
	//mem stage
	writeregM,
	regwriteM,
	memtoregM,
	stallM,flushM,

	//write back stage
	writeregW,
	regwriteW,
	stallW,flushW
    );

    //next PC logic (operates in fetch an decode)
    mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
    mux2 #(32) pcmux(pcnextbrFD,jumpInstD,njumpD,pcnextFD);

    mux2 #(32) jmpPcMux(
        {pcplus4D[31:28],instrD[25:0],2'b00}, srca2D,
        jrD,
        jumpInstD
    );

    //regfile (operates in decode and writeback)
    regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

    //fetch stage logic
    pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
    adder pcadd1(pcF,32'b100,pcplus4F);
    //decode stage
    flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
    flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
    signext se(instrD[15:0],signimmD);
    sl2 immsh(signimmD,signimmshD);
    adder pcadd2(pcplus4D,signimmshD,pcbranchD);
    mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
    mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
    eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);
    adder pcadd3(pcplus4D,32'b100,pcplus8D);

    assign opD    = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD    = instrD[25:21];
    assign rtD    = instrD[20:16];
    assign rdD    = instrD[15:11];
    assign saD    = instrD[10:6];


    //execute stage
    flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
    flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
    flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
    flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
    flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
    flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
    flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
    flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);

    mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
    mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
    mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);//b��1��imm��reg

    alu alu(
    .clk(clk),
    .rst(rst),
    .a(srca2E),
    .b(srcb3E),
    .sa(saE),
    .op(alucontrolE),
    .lo_o(lo_o),
    .hi_o(hi_o),
    .y(aluoutE),
    .overflow(overflowE),
    .zero(zeroE),
    .hilo_ena(hilo_ena),
    .hilo(aluoutE_64),
    .div_running(div_running)
    );

    hilo_reg hilo_reg(
        .clk(clk),
        .rst(rst),
        .we(hilo_ena),
        .hi_i(aluoutE_64[63:32]),
        .lo_i(aluoutE_64[31:0]),
        .hi_o(hi_o),
        .lo_o(lo_o)
    );

    mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);

    //mem stage
    flopenrc #(32) r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
    flopenrc #(32) r2M(clk,rst,~stallM,flushM,aluout2E,aluoutM);
    flopenrc #(5) r3M(clk,rst,~stallM,flushM,writereg2E,writeregM);
    flopenrc #(6) r4M(clk,rst,~stallM,flushM,alucontrolE,alucontrolM);

    mux2 #(32) wrmux1(aluoutE,pcplus8E,AnsSwE,aluout2E);
    mux2 #(32) wrmux2(writeregE,5'b11111,AddSwE,writereg2E);

	sw_select sw_select(
		.adesM(1'b0),
		.addressM(aluoutM),
		.alucontrolM(alucontrolM),
		.memwriteM(memwriteM)
	);

    //writeback stage
    flopenrc #(32) r1W(clk,rst,~stallW,flushW,aluoutM,aluoutW);
    flopenrc #(32) r2W(clk,rst,~stallW,flushW,readdataM,readdataW);
    flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
	flopenrc #(6) r4W(clk,rst,~stallM,flushM,alucontrolM,alucontrolW);

	lw_select lw_select(
		.adelW(1'b0),
		.aluoutW(aluoutW),
		.alucontrolW(alucontrolW),
		.lwresultW(readdataW),
		.resultW(readdata2W)
	);

    mux2 #(32) resmux(aluoutW,readdata2W,memtoregW,resultW);
endmodule
