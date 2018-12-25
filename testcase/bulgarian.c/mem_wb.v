`include "defines.v"

module mem_wb(

	input						clk,
	input 						rst,

	input [`StallBus]			stall,

	input [`RegBus]				mem_wdata,
	input [`RegAddrBus]			mem_wd,
	input 						mem_wreg,

	output reg [`RegBus]		wb_wdata,
	output reg [`RegAddrBus]	wb_wd,
	output reg 					wb_wreg    
	
);

	always @ (posedge clk or posedge rst) begin
		if(rst == `RstEnable) begin
			wb_wdata <= `ZeroWord;
			wb_wd    <= `NOPRegAddr;
			wb_wreg  <= `WriteDisable;
		end else if(stall[4] == `Stop && stall[5] == `NoStop) begin
			wb_wdata <= `ZeroWord;
			wb_wd    <= `NOPRegAddr;
			wb_wreg  <= `WriteDisable;
		end else if(stall[4] == `NoStop) begin
			wb_wdata <= mem_wdata;
			wb_wd    <= mem_wd;
			wb_wreg  <= mem_wreg;
		end
	end

endmodule