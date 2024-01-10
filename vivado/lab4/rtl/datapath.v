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
    input wire invalidD,  //
    output [31:0] instrD,//

    input wire memtoregE,
    input wire alusrcE,regdstE,
    input wire regwriteE,
    input wire[7:0] alucontrolE,
    output wire flushE,stallE,

    input wire memtoregM,
    input wire regwriteM,
    input wire AnsSwE,AddSwE, //
    output wire[31:0] aluout2M,writedata2M,
    output wire flushM,stallM,
	output wire[3:0] memwriteM,
    input wire[31:0] readdataM,
    input wire cp0weM,cp0swM,

    input wire memtoregW,
    input wire regwriteW,
    output wire flushW,stallW,
    output wire [31:0] pcW,resultW,
    output wire [4:0] writeregW
);

    //fetch stage
    wire stallF;
    //FD
    wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,jumpInstD;
    wire is_in_delayslotF;
    wire [31:0] e_pcNext;
    wire [1:0] epc_swF;
    //decode stage
    wire [31:0] pcplus4D,pcplus8D;
    wire forwardaD,forwardbD,jrb_l_astall,jrb_l_bstall,is_in_delayslotD;
    wire [4:0] rsD,rtD,rdD,saD;
    wire flushD,stallD;
    wire [31:0] signimmD,signimmshD;
    wire [31:0] srcaD,srca2D,srcbD,srcb2D;
    wire [31:0] pcD;
    wire [7:0] exceptD;
    wire AddErrD,syscallD,breakD,eretD;
    //execute stage
    wire [1:0] forwardaE,forwardbE;
    wire [4:0] rsE,rtE,rdE,saE;
    wire [4:0] writeregE,writereg2E;
    wire [31:0] signimmE;
    wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
    wire [31:0] aluoutE,aluout2E;
    wire [31:0] pcplus8E;
    wire [31:0] pcE;
    wire is_in_delayslotE;
    wire [7:0] exceptE;
    //mem stage
    wire [4:0] writeregM,rdM;
	wire [7:0] alucontrolM;
    wire [31:0] writedataM;
    wire [31:0] pcM;
    wire is_in_delayslotM;
    wire [7:0] exceptM,except2M;
    wire adelM;
    wire adesM;
    wire [31:0] srcbM;
    wire [31:0] aluoutM;
    //writeback stage
    // wire [4:0] writeregW;  输出给debug�????
    wire [31:0] aluoutW,readdataW;
    wire divstallE;
    wire overflowE,zeroE;
    wire [63:0] aluoutE_64;
    wire [31:0] hi_o;
    wire [31:0] lo_o;
    wire hilo_ena;
    wire div_running;
	wire [7:0] alucontrolW;
	wire [31:0] readdata2W;
    wire adelW;

    //hazard detection
    hazard h(
    stallF,flushF,
    epc_swF,
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
	(div_running),
	forwardaE,forwardbE,
	stallE,flushE,
	//mem stage
	writeregM,
	regwriteM,
	memtoregM,
	stallM,flushM,
    excepttype,

	//write back stage
	writeregW,
	regwriteW,
	stallW,flushW
    );

    //next PC logic (operates in fetch an decode)
    mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
    mux2 #(32) pcmux(pcnextbrFD,jumpInstD,njumpD,pcnextFD);
    mux3 #(32) epcmux(pcnextFD,epc,32'hbfc00380,epc_swF,e_pcNext);

    mux2 #(32) jmpPcMux(
        {pcplus4D[31:28],instrD[25:0],2'b00}, srca2D,
        jrD,
        jumpInstD
    );

    //regfile (operates in decode and writeback)
    regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

    //fetch stage logic
    pc #(32) pcreg(clk,rst,~stallF,e_pcNext,pcF);
    adder pcadd1(pcF,32'b100,pcplus4F);
    assign is_in_delayslotF = njumpD | branchD ;

    //decode stage
    flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
    flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
    flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
    flopenrc #(1) r4D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
    signext se(instrD[15:0],signimmD);
    sl2 immsh(signimmD,signimmshD);
    adder pcadd2(pcplus4D,signimmshD,pcbranchD);
    mux2 #(32) forwardamux(srcaD,aluout2M,forwardaD,srca2D);
    mux2 #(32) forwardbmux(srcbD,aluout2M,forwardbD,srcb2D);
    eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);
    adder pcadd3(pcplus4D,32'b100,pcplus8D);

    assign opD    = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD    = instrD[25:21];
    assign rtD    = instrD[20:16];
    assign rdD    = instrD[15:11];
    assign saD    = instrD[10:6];

    assign AddErrD = pcD[1:0]!=2'b00;
    assign syscallD = (opD == 6'b000000 && functD == 6'b001100);
    assign breakD =  (opD == 6'b000000 && functD == 6'b001101);
    assign eretD = (instrD == 32'b01000010000000000000000000011000);

    assign exceptD = {AddErrD,syscallD,breakD,eretD,invalidD,3'b0};


    //execute stage
    flopenrc #(32) r1E(clk,rst,~stallE,flushE,srca2D,srcaE);
    flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcb2D,srcbE);
    flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
    flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
    flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
    flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
    flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
    flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
    flopenrc #(32) r9E(clk,rst,~stallE,flushE,pcD,pcE);
    flopenrc #(1) r10E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);
    flopenrc #(8) r11E(clk,rst,~stallE,flushE,exceptD,exceptE);

    mux3 #(32) forwardaemux(srcaE,resultW,aluout2M,forwardaE,srca2E);
    mux3 #(32) forwardbemux(srcbE,resultW,aluout2M,forwardbE,srcb2E);
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
        .we(hilo_ena &  (!flushE)),
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
    flopenrc #(8) r4M(clk,rst,~stallM,flushM,alucontrolE,alucontrolM);
    flopenrc #(32) r5M(clk,rst,~stallM,flushM,pcE,pcM);
    flopenrc #(1) r6M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
    flopenrc #(8) r7M(clk,rst,~stallM,flushM,{exceptE[7:3],overflowE,2'b0},exceptM);
    flopenrc #(5) r8M(clk,rst,~stallM,flushM,rdE,rdM);
    flopenrc #(32) r9M(clk,rst,~stallM,flushM,srcb3E,srcbM);


    mux2 #(32) wrmux1(aluoutE,pcplus8E,AnsSwE,aluout2E);
    mux2 #(32) wrmux2(writeregE,5'b11111,AddSwE,writereg2E);
    mux2 #(32) op0mux(aluoutM,cp0data,cp0swM,aluout2M);

	sw_select sw_select(
		.adesM(adesM),
		.addressM(aluoutM),
		.alucontrolM(alucontrolM),
		.memwriteM(memwriteM)
	);

    addr_except aexc(
        .addrs(aluoutM),
        .alucontrolM(alucontrolM),
        .adelM(adelM),
        .adesM(adesM)
    );

    assign except2M = exceptM | {adesM,adelM};


    wire [31:0] excepttype,bad_addr,cp0data,cp0_status,cp0_cause,epc;
//                                                                ^



    exception exc(
     .rst(rst),
	 .pcM(pcM),
	 .exceptM(except2M),
	 .cp0_status(cp0_status),
     .cp0_cause(cp0_cause),
     .aluoutM(aluoutM),
	 .excepttype(excepttype),
     .bad_addr(bad_addr)
    );

    cp0_reg cp0(
     .clk(clk),
	 .rst(rst),

	 .we_i(cp0weM),
	 .waddr_i(rdM),
	 .raddr_i(rdM),
	 .data_i(srcbM),

     .int_i(6'b0),

     .excepttype_i(excepttype),
	 .current_inst_addr_i(pcM),
	 .is_in_delayslot_i(is_in_delayslotM),
	 .bad_addr_i(bad_addr),

     .count_o(),
	 .data_o(cp0data), //
	 .compare_o(),
	 .status_o(cp0_status),
	 .cause_o(cp0_cause),
	 .epc_o(epc),
	 .config_o(),
	 .prid_o(),
	 .badvaddr(),
     .timer_int_o()
	    );





    assign writedata2M = (alucontrolM == `EXE_SB_OP)? {{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]}}:
                    (alucontrolM == `EXE_SH_OP)? {{writedataM[15:0]},{writedataM[15:0]}}:
                    (alucontrolM == `EXE_SW_OP)? {{writedataM[31:0]}}:
                    writedataM;

    //writeback stage
    flopenrc #(32) r1W(clk,rst,~stallW,flushW,aluout2M,aluoutW);
    flopenrc #(32) r2W(clk,rst,~stallW,flushW,readdataM,readdataW);
    flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
	flopenrc #(8) r4W(clk,rst,~stallW,flushW,alucontrolM,alucontrolW);
    flopenrc #(32) r5W(clk,rst,~stallW,flushW,pcM,pcW);
    flopenrc #(1) r6W(clk,rst,~stallM,flushM,adelM,adelW);

	lw_select lw_select(
		.adelW(adelW),
		.aluoutW(aluoutW),
		.alucontrolW(alucontrolW),
		.lwresultW(readdataW),
		.resultW(readdata2W)
	);

    mux2 #(32) resmux(aluoutW,readdata2W,memtoregW,resultW);
endmodule
