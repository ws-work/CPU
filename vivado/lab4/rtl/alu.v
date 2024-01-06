// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company:
// // Engineer:
// //
// // Create Date: 2017/11/02 14:52:16
// // Design Name:
// // Module Name: alu
// // Project Name:
// // Target Devices:
// // Tool Versions:
// // Description:
// //
// // Dependencies:
// //
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// //
// //////////////////////////////////////////////////////////////////////////////////
// `include "defines2.vh"

// module alu(
// 	input wire clk,rst,
// 	input wire[31:0] a,b,
// 	input wire[4:0] sa,
// 	input wire[5:0] op,
// 	input wire[31:0] lo_o,
// 	input wire[31:0] hi_o,
// 	output reg[31:0] y,
// 	output overflow,
// 	output wire zero,
// 	output wire hilo_ena,
// 	output reg [63:0] hilo,
// 	output wire div_running //div在运行时，暂停流水线
//     );

// wire [31:0] subresult,mult_a,mult_b;
// wire [63:0] hilo_tmp;


// wire signed_div_i,start_i,annul_i,ready_o;
// wire [31:0] opdata1_i,opdata2_i;

// // assign div_stall = !(rst | ready_o);
// assign signed_div_i = (op == `DIV)? 1'b1: 1'b0;
// assign start_i = ((op == `DIV || op == `DIVU) && ~ready_o)? 1'b1: 1'b0;
// assign div_running = start_i;
// assign annul_i =1'b0;

// assign {opdata1_i,opdata2_i} =  (op == `DIV | op == `DIVU) ? { a , b } : 64'b0;


// div div(
// 	.clk(clk),
// 	.rst(rst),
// 	.signed_div_i(signed_div_i),
// 	.opdata1_i(opdata1_i),
// 	.opdata2_i(opdata2_i),
// 	.start_i(start_i),
// 	.annul_i(annul_i),
// 	.result_o(result_o),
// 	.ready_o(ready_o)
// );


// assign mult_a = a[31] == 1'b1 ? (~a + 1) : a;
// assign mult_b = b[31] == 1'b1 ? (~b + 1) : b;

// assign hilo_tmp = (op == `MULT) ? ((a[31]^b[31] == 1'b1)? ~(mult_a*mult_b)+1 :mult_a*mult_b) /*$signed(mult_a)*$signed(mult_b)*/:
// 			      (op == `MULTU) ? (a*b)	:
// 			      64'b0;

// assign hilo_ena = (op ==  `MULT) || (op == `MULTU) || (op == `MTHI) || (op == `MTLO) || (op == `DIV) || (op == `DIVU)? 1'b1 :1'b0;


// assign overflow = (op == 100000)? (y[31] && !a[31] && !b[31]) || (!y[31] && a[31] && b[31]):
//                   (op == 100010)? ((a[31]&!b[31])&!y[31]) || ((!a[31]&b[31])&y[31]):
//                   1'b0;
// assign subresult = a + (~b + 1);
// 	always @(*) begin
// 		case (op)
// 			6'b000000: y <= b << sa;
// 			6'b000010: y <= b >> sa;
// 			6'b000011: y <= ({32{b[31]}} << (6'd32 - {1'b0,sa})) | b>>sa ;
// 			6'b000100: y <= b << a[4:0];
// 			6'b000110: y <= b >> a[4:0];
// 			6'b000111: y <= ({32{b[31]}} << (6'd32 - {1'b0,a[4:0]})) | b>>a[4:0];
// 			6'b100100: y <= a & b;
// 			6'b110100: y <= a & { {16{1'b0}} ,b[15:0]};
// 			6'b100101: y <= a | b;
// 			6'b110101: y <= a | { {16{1'b0}} ,b[15:0]};
// 			6'b100110: y <= a ^ b;
// 			6'b110111: y <= a ^ { {16{1'b0}} ,b[15:0]};
// 			6'b100111: y <= ~(a|b);
// 			6'b001000: y <= {b[15:0],{16{1'b0}}};

// 			6'b101010: y <= (a[31] && !b[31]) || (!a[31] && !b[31] && subresult[31]) || (a[31] && b[31] && subresult[31]);

// 			6'b100000,6'b100001: y <= a + b;                //add
// 			6'b100010,6'b100011: y <= a + (~b + 1);         //sub

// 			6'b101010: y <=  $signed(a)<$signed(b) ? 1 : 0; //slt
// 		    6'b101011: y <= a < b ? 1 : 0;					//sltu

// 			`MULT:     hilo <= hilo_tmp;
// 		    `MULTU:    hilo <= hilo_tmp;
// 			`DIV:      hilo <= result_o;

// 			`MFHI:     y <= hi_o;
// 			`MFLO:     y <= lo_o;
// 			`MTHI:     hilo <= {a,lo_o};
// 			`MTLO:	   hilo <= {hi_o,a};



// 			default : y <= 32'b0;
// 		endcase
// 	end
// 	assign zero = (y == 32'b0);

// //	always @(*) begin
// //		case (op[2:1])
// //			2'b01:overflow <= a[31] & b[31] & ~s[31] |
// //							~a[31] & ~b[31] & s[31];
// //			2'b11:overflow <= ~a[31] & b[31] & s[31] |
// //							a[31] & ~b[31] & ~s[31];
// //			default : overflow <= 1'b0;
// //		endcase
// //	end
// endmodule





`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/11/02 14:52:16
// Design Name:
// Module Name: alu
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
`include "defines2.vh"

module alu(
	input wire clk,rst,
	input wire[31:0] a,b,
	input wire[4:0] sa,
	input wire[5:0] op,
	input wire[31:0] lo_o,
	input wire[31:0] hi_o,
	output reg[31:0] y,
	output overflow,
	output wire zero,
	output wire hilo_ena,
	output reg [63:0] hilo,
	output reg div_running //div在运行时，暂停流水线
    );

wire [31:0] subresult,mult_a,mult_b;
wire [63:0] hilo_tmp;

reg start_i;
wire signed_div_i,annul_i,ready_o;
wire [31:0] opdata1_i,opdata2_i;
wire [63:0] result_o;

assign signed_div_i = (op == `DIV)? 1'b1: 1'b0;
assign annul_i =1'b0;


always @(rst)begin
	start_i <= 1'b0;
	div_running <= 1'b0;
end

// always @(posedge clk)begin
// 	if (!div_running)begin
// 		opdata1_i <= a;
// 		opdata2_i <= b;
// 	end
// end

assign {opdata1_i,opdata2_i} =  (op == `DIV | op == `DIVU) ? { a , b } : 64'b0;


div div(
	.clk(clk),
	.rst(rst),
	.signed_div_i(signed_div_i),
	.opdata1_i(opdata1_i),
	.opdata2_i(opdata2_i),
	.start_i(start_i),
	.annul_i(annul_i),
	.result_o(result_o),
	.ready_o(ready_o)
);


assign mult_a = a[31] == 1'b1 ? (~a + 1) : a;
assign mult_b = b[31] == 1'b1 ? (~b + 1) : b;

assign hilo_tmp = (op == `MULT) ? ((a[31]^b[31] == 1'b1)? ~(mult_a*mult_b)+1 :mult_a*mult_b) /*$signed(mult_a)*$signed(mult_b)*/:
			      (op == `MULTU) ? (a*b)	:
			      64'b0;

assign hilo_ena = (op ==  `MULT) || (op == `MULTU) || (op == `MTHI) || (op == `MTLO) || (op == `DIV) || (op == `DIVU)? 1'b1 :1'b0;

assign overflow = (op == 100000)? (y[31] && !a[31] && !b[31]) || (!y[31] && a[31] && b[31]):
                  (op == 100010)? ((a[31]&!b[31])&!y[31]) || ((!a[31]&b[31])&y[31]):
                  1'b0;

assign subresult = a + (~b + 1);

always @(*) begin
	case (op)
		6'b000000: y <= b << sa;
		6'b000010: y <= b >> sa;
		6'b000011: y <= ({32{b[31]}} << (6'd32 - {1'b0,sa})) | b>>sa ;
		6'b000100: y <= b << a[4:0];
		6'b000110: y <= b >> a[4:0];
		6'b000111: y <= ({32{b[31]}} << (6'd32 - {1'b0,a[4:0]})) | b>>a[4:0];
		6'b100100: y <= a & b;
		6'b110100: y <= a & { {16{1'b0}} ,b[15:0]};
		6'b100101: y <= a | b;
		6'b110101: y <= a | { {16{1'b0}} ,b[15:0]};
		6'b100110: y <= a ^ b;
		6'b110111: y <= a ^ { {16{1'b0}} ,b[15:0]};
		6'b100111: y <= ~(a|b);
		6'b001000: y <= {b[15:0],{16{1'b0}}};

		6'b101010: y <= (a[31] && !b[31]) || (!a[31] && !b[31] && subresult[31]) || (a[31] && b[31] && subresult[31]);

		6'b100000,6'b100001: y <= a + b;                //add
		6'b100010,6'b100011: y <= a + (~b + 1);         //sub

		6'b101010: y <=  $signed(a)<$signed(b) ? 1 : 0; //slt
		6'b101011: y <= a < b ? 1 : 0;					//sltu

		`MULT:     hilo <= hilo_tmp;
		`MULTU:    hilo <= hilo_tmp;
		`DIV,`DIVU:begin
				if (ready_o == 1'b0)begin
					start_i <= 1'b1;
					div_running <= 1'b1;
				end else if(ready_o == 1'b1) begin
					start_i <= 1'b0;
					div_running <= 1'b0;
					hilo <= result_o;
				end
			end

		`MFHI:     y <= hi_o;
		`MFLO:     y <= lo_o;
		`MTHI:     hilo <= {a,lo_o};
		`MTLO:	   hilo <= {hi_o,a};



		default : y <= 32'b0;
	endcase
end
assign zero = (y == 32'b0);

//	always @(*) begin
//		case (op[2:1])
//			2'b01:overflow <= a[31] & b[31] & ~s[31] |
//							~a[31] & ~b[31] & s[31];
//			2'b11:overflow <= ~a[31] & b[31] & s[31] |
//							a[31] & ~b[31] & ~s[31];
//			default : overflow <= 1'b0;
//		endcase
//	end
endmodule
