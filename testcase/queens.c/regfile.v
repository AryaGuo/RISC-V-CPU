`include "defines.v"

module regfile(
	input 					clk,
	input 					rst,

	input [`RegAddrBus]		rd_addr_0,
	input [`RegAddrBus]		rd_addr_1,
	input 					re_0,
	input 					re_1,

	output reg [`RegBus]	rd_data_0,
	output reg [`RegBus]	rd_data_1,

	input 					we,
	input [`RegAddrBus]		wr_addr,
	input [`RegBus]			wr_data
);

	reg [`RegBus]			gpr[0:`RegNum-1];

	integer					i;

	//read
	always @(*) begin
		if (rst == `RstEnable) begin
			rd_data_0 <= `ZeroWord;
			rd_data_1 <= `ZeroWord;
		end else begin
			if (re_0 == `ReadEnable) begin
				rd_data_0 <= (we && wr_addr == rd_addr_0) ? wr_data : gpr[rd_addr_0];	
			end
			if (re_1 == `ReadEnable) begin
				rd_data_1 <= (we && wr_addr == rd_addr_1) ? wr_data : gpr[rd_addr_1];
			end
		end
	end
	
	//write
	always @(posedge clk or posedge rst) begin
		if (rst == `RstEnable) begin
			for (i = 0; i < `RegNum; i = i + 1) begin 
				gpr[i] <= #1 `ZeroWord;
			end
		end else begin
			if (we && wr_addr) begin
				gpr[wr_addr] <= #1 wr_data;
				// $display ("wirte %x to %d", wr_data, wr_addr);
			end
		end
	end

endmodule