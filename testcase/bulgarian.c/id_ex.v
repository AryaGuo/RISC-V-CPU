`include "defines.v"

module id_ex(

	input 						clk,
	input 						rst,

	input [`StallBus]			stall,
	input						flush,
	
	input [`OpcodeBus]			id_op,
	input [`Fun3Bus]			id_fun3,
	input [`Fun7Bus]			id_fun7,
	input [`RegBus]				id_reg1,
	input [`RegBus]				id_reg2,
	input [`RegAddrBus]			id_wd,
	input 						id_wreg,
	input [`RegBus]				id_base,
	input [`RegBus]				id_offset,	
	
	output reg [`OpcodeBus]		ex_op,
	output reg [`Fun3Bus]		ex_fun3,
	output reg [`Fun7Bus]		ex_fun7,
	output reg [`RegBus]		ex_reg1,
	output reg [`RegBus]		ex_reg2,
	output reg [`RegAddrBus]	ex_wd,
	output reg 					ex_wreg,
	output reg [`RegBus]		ex_base,
	output reg [`RegBus]		ex_offset

);

	always @(posedge clk or posedge rst) begin
		if (rst == `RstEnable) begin
			ex_op     <= `OP_NOP;
			ex_fun3   <= `FUN3_NOP;
			ex_fun7   <= `FUN7_NOP;
			ex_reg1   <= `ZeroWord;
			ex_reg2   <= `ZeroWord;
			ex_wd     <= `NOPRegAddr;
			ex_wreg   <= `WriteDisable;
			ex_base   <= `ZeroWord;
			ex_offset <= `ZeroWord;
		end else if((stall[2] == `Stop && stall[3] == `NoStop) || flush == `Flush) begin 
			ex_op     <= `OP_NOP;
			ex_fun3   <= `FUN3_NOP;
			ex_fun7   <= `FUN7_NOP;
			ex_reg1   <= `ZeroWord;
			ex_reg2   <= `ZeroWord;
			ex_wd     <= `NOPRegAddr;
			ex_wreg   <= `WriteDisable;
			ex_base   <= `ZeroWord;
			ex_offset <= `ZeroWord;
		end else if(stall[2] == `NoStop) begin
			ex_op     <= id_op;
			ex_fun3   <= id_fun3;
			ex_fun7   <= id_fun7;
			ex_reg1   <= id_reg1;
			ex_reg2   <= id_reg2;
			ex_wd     <= id_wd;
			ex_wreg   <= id_wreg;
			ex_base   <= id_base;
			ex_offset <= id_offset;
		end
	end
endmodule