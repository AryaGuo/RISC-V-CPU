`include "defines.v"

module mem(

	input						rst,

	input [`RegBus]				wdata_i,
	input [`RegAddrBus]			wd_i,
	input 						wreg_i,

	input [`MemOpBus]			mem_op_i,
	input [`MemAddrBus]			mem_addr_i,
	input [`RegBus]				mem_data_i,
	input [`MemSelBus]			mem_sel_i,
	input						mem_extend_i,

//from mem_ctrl
	input						done,
	input [`RegBus]				get_data,

//to mem/wb
	output reg [`RegBus]		wdata_o,
	output reg [`RegAddrBus]	wd_o,
	output reg 					wreg_o,

//to mem_ctrl
	output reg [`MemOpBus]		mem_op_o,
	output reg [`MemAddrBus]	mem_addr_o,
	output reg [`RegBus]		mem_data_o,
	output reg [`MemSelBus]		mem_sel_o,
	output reg 					mem_extend_o,

	output reg 					stall_req
	
);

	always @ (*) begin
		if(rst == `RstEnable) begin
			wdata_o     <= `ZeroWord;
			wreg_o      <= `WriteDisable;
			wd_o        <= `NOPRegAddr;
			mem_op_o    <= `MemDisable;
			mem_addr_o  <= `ZeroMemAddr;
			mem_data_o  <= `ZeroWord;
			mem_sel_o   <= `MemSelEmpty;
			mem_extend_o <= `SEXT;
			stall_req   <= `NoStop;
		end else begin
			wreg_o    	<= wreg_i;
			wd_o 		<= wd_i;
			mem_op_o     <= mem_op_i;
			mem_addr_o   <= mem_addr_i;
			mem_data_o   <= mem_data_i;
			mem_sel_o    <= mem_sel_i;
			mem_extend_o <= mem_extend_i;
			case (mem_op_i)
				`MemDisable: begin
					wdata_o      <= wdata_i;
					stall_req    <= `NoStop;
				end
				`MemRead: begin
					wdata_o      <= get_data;
					stall_req    <= done == `Busy ? `Stop : `NoStop;
				end
				`MemWrite: begin
					wdata_o      <= wdata_i;
					stall_req    <= done == `Busy ? `Stop : `NoStop;
				end
			endcase
		end
	end

endmodule