module mycpu_top(
    input clk,
    input resetn,  //low active
    input wire [5:0] ext_int,

    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    //debug
	output wire [31:0] debug_wb_pc,
	output wire [3:0] debug_wb_rf_wen,
	output wire [4:0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
);

	wire [31:0] pc;
	wire [31:0] instr;
	wire [3:0] memwrite;
	wire [31:0] aluout, writedata, readdata;

    wire [31:0] pcW,resultW;
    wire [4:0] writeregW;
    wire regwriteW,mem_enM;

    mips mips(
        .clk(clk),
        .rst(~resetn),
        //instr
        // .inst_en(inst_en),
        .pcconvertF(pc),                    //pcF
        .instrF(instr),              //instrF
        //data
        // .data_en(data_en),
        .memwriteM(memwrite),
        .dataadr(aluout),
        .writedataM(writedata),
        .readdataM(readdata),
        .pcW(pcW),
        .resultW(resultW),
        .writeregW(writeregW),
        .regwriteW(regwriteW),
		.mem_enM(mem_enM)
    );

    assign inst_sram_en = 1'b1;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pc;
    assign inst_sram_wdata = 32'b0;
    assign instr = inst_sram_rdata;

    assign data_sram_en = mem_enM;
    assign data_sram_wen = memwrite;
    assign data_sram_addr = aluout;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;

    assign	debug_wb_pc			= pcW;
	assign	debug_wb_rf_wen		= {4{regwriteW}};
	assign	debug_wb_rf_wnum	= writeregW;
	assign	debug_wb_rf_wdata	= resultW;

    //ascii
    instdec instdec(
        .instr(instr)
    );

endmodule