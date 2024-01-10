`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/01/09 21:32:51
// Design Name:
// Module Name: exception
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


module exception(
	input rst,
	input [31:0] pcM,
	input [7:0] exceptM,
	input wire[31:0] cp0_status,cp0_cause,aluoutM,
	output reg [31:0] excepttype,bad_addr
    );

	// exception input:
	// 0: adelM  1: adesM  2: overflow  3: invalid  4: eret  5:break  6: syscall  7: addErr


	always @(*) begin
		if (rst) excepttype <= 32'h0000_0000;
		else begin
			if ((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00 &&
					cp0_status[1] == 1'b0 && cp0_status[0] == 1'b1)
				excepttype <= 32'h0000_0001;
			else if (exceptM[7] || exceptM[0]) excepttype <= 32'h0000_0004;	// adelM
			else if (exceptM[1]) excepttype <= 32'h0000_0005;	// adesM
			else if (exceptM[2]) excepttype <= 32'h0000_000c;	// overflow
			else if (exceptM[4]) excepttype <= 32'h0000_000e;	// eret
			else if (exceptM[5]) excepttype <= 32'h0000_0009;	// break
			else if (exceptM[6]) excepttype <= 32'h0000_0008;	// syscall
			else if (exceptM[3]) excepttype <= 32'h0000_000a;	// invalid
	     else excepttype <= 32'h0;
		end
	end

	always @(*) begin
		if (rst) bad_addr <= 32'h0000_0000;
		else begin
			if ((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00 &&
					cp0_status[1] == 1'b0 && cp0_status[0] == 1'b1)
				bad_addr <= 32'h0000_0000;
			else if (exceptM[7]) bad_addr <= pcM;
			else if (exceptM[1] == 1) bad_addr <= aluoutM;
			else if (exceptM[0] == 1) bad_addr <= aluoutM;
	     else bad_addr <= 32'h0;
		end
	end
endmodule

