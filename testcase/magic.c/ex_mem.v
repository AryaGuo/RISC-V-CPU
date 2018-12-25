`include "defines.v"

module ex_mem(

	input						clk,
	input						rst,

	input [`StallBus]			stall,

	input [`RegBus]				ex_wdata,
	input [`RegAddrBus]			ex_wd,
	input 						ex_wreg,


	input [`MemOpBus]			ex_me_op,
	input [`MemAddrBus]			ex_me_addr,
	input [`RegBus]				ex_me_data,
	input [`MemSelBus]			ex_me_sel,
	input 						ex_me_extend,

	output reg [`RegBus]		mem_wdata,
	output reg [`RegAddrBus]	mem_wd,
	output reg 					mem_wreg,

	output reg [`MemOpBus]		mem_me_op,
	output reg [`MemAddrBus]	mem_me_addr,
	output reg [`RegBus]		mem_me_data,
	output reg [`MemSelBus]		mem_me_sel,
	output reg 					mem_me_extend

);

	always @ (posedge clk or posedge rst) begin
		if(rst == `RstEnable) begin
			mem_wdata     <= `ZeroWord;
			mem_wd        <= `NOPRegAddr;
			mem_wreg      <= `WriteDisable;
			mem_me_op     <= `MemDisable;
			mem_me_addr   <= `ZeroMemAddr;
			mem_me_data   <= `ZeroWord;
			mem_me_sel    <= `MemSelEmpty;
			mem_me_extend <= `SEXT;
		end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
			mem_wdata     <= `ZeroWord;
			mem_wd        <= `NOPRegAddr;
			mem_wreg      <= `WriteDisable;
			mem_me_op     <= `MemDisable;
			mem_me_addr   <= `ZeroMemAddr;
			mem_me_data   <= `ZeroWord;
			mem_me_sel    <= `MemSelEmpty;
			mem_me_extend <= `SEXT;
		end else if(stall[3] == `NoStop) begin
			mem_wdata     <= ex_wdata;
			mem_wd        <= ex_wd;
			mem_wreg      <= ex_wreg;
			mem_me_op     <= ex_me_op;
			mem_me_addr   <= ex_me_addr;
			mem_me_data   <= ex_me_data;
			mem_me_sel    <= ex_me_sel;
			mem_me_extend <= ex_me_extend;
		end
	end

endmodule