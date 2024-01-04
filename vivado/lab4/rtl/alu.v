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

module alu(
	input wire[31:0] a,b,
	input wire[4:0] sa,
	input wire[5:0] op,
	output reg[31:0] y,
	output overflow,
	output wire zero
    );

wire [31:0] subresult;



assign overflow = (op == 100000)? (y[31] && !a[31] && !b[31]) || (!y[31] && a[31] && b[31]):
                  (op == 100010)? ((a[31]&!b[31])&!y[31]) || ((!a[31]&b[31])&y[31]):
                  1'b0;
assign subresult = a + (~b + 1);
	always @(*) begin
		case (op)
			6'b000000: y <= b << sa;
			6'b000010: y <= b >> sa;
			6'b000011: y <= ({32{b[31]}} << (6'd32 - {1'b0,sa})) | b>>sa ;
			6'b000100: y <= b << a;
			6'b000110: y <= b >> a;
			6'b000111: y <= ({32{b[31]}} << (6'd32 - {1'b0,a[4:0]})) | b>>a[4:0];
			6'b100100: y <= a & b;
			6'b110100: y <= a & { {16{1'b0}} ,b[15:0]};
			6'b100101: y <= a | b;
			6'b110101: y <= a | { {16{1'b0}} ,b[15:0]};
			6'b100110: y <= a ^ b;
			6'b110111: y <= a ^ { {16{1'b0}} ,b[15:0]};
			6'b100111: y <= ~(a|b);
			6'b001000: y <= {b[15:0],b[31:16]};

			6'b101010: y <= (a[31] && !b[31]) || (!a[31] && !b[31] && subresult[31]) || (a[31] && b[31] && subresult[31]);

			6'b100000,6'b100001: y <= a + b;                //add
			6'b100010,6'b100011: y <= a + (~b + 1);         //sub

			6'b101010: y <=  $signed(a)<$signed(b) ? 1 : 0; //slt
		    6'b101011: y <= a < b ? 1 : 0;					//sltu



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
