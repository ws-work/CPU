`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/11/22 10:23:13
// Design Name:
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,flushF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,jumpD,jrD, //
	output wire forwardaD,forwardbD,
	output wire jrb_l_astall,jrb_l_bstall,//
	output wire stallD,flushD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire div_running,
	output reg[1:0] forwardaE,forwardbE,
	output wire stallE,flushE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	output wire stallM,flushM,

	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire stallW,flushW
    );

	wire lwstallD,branchstallD;

	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);

	//forwarding sources to E stage (ALU)

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

	//stalls
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign branchstallD = branchD &
				(regwriteE &
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
	assign jrstall = jrD && regwriteE && (writeregE==rsD);//jr
	//branch/jr时数据前推 ??用途不明??
    assign jrb_l_astall = (jrD|branchD) && ((memtoregE && (writeregE==rsD)) || (memtoregM && (writeregM==rsD)));
	assign jrb_l_bstall = (jrD|branchD) && ((memtoregE && (writeregE==rtD)) || (memtoregM && (writeregM==rtD)));


	assign stallD = lwstallD | branchstallD | div_running | jrstall;
	assign stallF = stallD;
	assign stallE = div_running;
	assign stallM = stallE;
	assign stallW = stallE;
		//stalling D stalls all previous stages


	assign #1 flushF = 1'b0;
	assign #1 flushD = 1'b0;
	assign #1 flushE = lwstallD | branchstallD | jumpD;
	assign #1 flushM = 1'b0;
	assign #1 flushW = 1'b0;

		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
endmodule





// /*hazard模块
//     冒险处理模块，判断是否数据前推、暂停流水线、清空流水线等操作，异常指令时要刷新流水线
// */
// `timescale 1ns / 1ps
// `include "defines.vh"

// module hazard(
//     // F 阶段
//     output wire stallF,
//     output wire [31:0] newPC,
// 	output flushF,
//     // D 阶段
//     input wire [4:0] rsD,rtD,
//     input wire branchD,jumpD,jrD,
//     input wire [7:0] alucontrolD,
//     output wire forwardaD,forwardbD,jrforwardaD,stallD,jrb_l_astall,jrb_l_bstall,
//     output flushD,
//     // E 阶段
//     input wire [4:0] rsE,rtE,writeregE,
//     input wire regwriteE,memtoregE,
//     input wire hilo_signal,
//     input wire [7:0] alucontrolE,
//     input wire  div_ready,
//     output wire [1:0]forwardaE,forwardbE,
//     output wire flushE,stallE,
//     // M 阶段
//     input wire [4:0] writeregM,
//     input wire regwriteM,memtoregM,
//     input wire[31:0] exception_type,
//     input wire overflowM,
//     output wire flushM,
//     input wire [31:0] epc,
//     // W 阶段
//     input wire [4:0] writeregW,
//     input wire regwriteW,
//     output wire flushW
//     );

//     wire lwstallD,branchstallD,jrstall,stall_divE;

//     // ---------------------- expt back pc -----------------------
//     assign newPC = (exception_type == 32'h0000_0001)? 32'hbfc00380:
//                    (exception_type == 32'h0000_0004)? 32'hbfc00380:
//                    (exception_type == 32'h0000_0005)? 32'hbfc00380:
//                    (exception_type == 32'h0000_0008)? 32'hbfc00380:
//                    (exception_type == 32'h0000_0009)? 32'hbfc00380:
//                    (exception_type == 32'h0000_000a)? 32'hbfc00380:
//                    (exception_type == 32'h0000_000c)? 32'hbfc00380:
//                    (exception_type == 32'h0000_000e)? epc:
//                    32'b0;

//     // ------------------------ forwading ------------------------
//     //branch指令在D阶段判断是否跳转可能出现数据冒险，见datapath
//     assign forwardaD = (rsD !=0 & rsD == writeregM & regwriteM);
//     assign forwardbD = ((rtD !=0) & rtD == writeregM & regwriteM);
//     assign forwardaE =  ((rsE != 0) & rsE==writeregM & regwriteM) ? 2'b10:
// 					   	((rsE != 0) & rsE==writeregW & regwriteW) ? 2'b01: 2'b00;
// 	assign forwardbE = 	((rtE != 0) & rtE==writeregM & regwriteM) ? 2'b10:
// 					   	((rtE != 0) & rtE==writeregW & regwriteW) ? 2'b01: 2'b00;

//     // -------------------------- stall --------------------------
//     //除法，暂停流水线
//     assign stall_divE = ((alucontrolE == `EXE_DIV_OP)|(alucontrolE == `EXE_DIVU_OP)) & ~div_ready;
//     //lw时寄存器还没写入，暂停流水线
//     assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
//     //branch时数据前推也没能写入寄存器，暂停流水线
//     assign  branchstallD = (branchD & regwriteE & (writeregE == rsD | writeregE == rtD)) | (branchD & memtoregM &(writeregM == rsD | writeregM == rtD));
//     //jr时数据前推也没能写入寄存器，暂停流水线
//     assign jrstall = jrD && regwriteE && (writeregE==rsD);
//     //branch/jr时数据前推  ??用途不明??
//     assign jrb_l_astall = (jrD|branchD) && ((memtoregE && (writeregE==rsD)) || (memtoregM && (writeregM==rsD)));
// 	assign jrb_l_bstall = (jrD|branchD) && ((memtoregE && (writeregE==rtD)) || (memtoregM && (writeregM==rtD)));
//     //暂停流水线
//     assign  stallF = stallD;
//     assign  stallD = lwstallD | branchstallD | stall_divE | jrstall;
//     assign  stallE = stall_divE;

//     // ------------------------- flush -------------------------
//     assign flushF=(exception_type!=0);
// 	assign flushD=(exception_type!=0);
//  assign flushE = lwstallD | branchstallD |(exception_type!=0);
// 	assign flushM=(exception_type!=0);
// 	assign flushW=(exception_type!=0);
// endmodule
