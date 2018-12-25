`include "defines.v"

module if_id(

	input						clk,
	input						rst,

	input [`StallBus]			stall,
	input						flush,
	
	input [`InstAddrBus]		if_pc,
	input [`InstBus]			if_inst,

	output reg[`InstAddrBus]	id_pc,
	output reg[`InstBus]		id_inst  
	
);

	always @ (posedge clk or posedge rst) begin
		if (rst == `RstEnable) begin
			id_pc   <= `ZeroWord;
			id_inst <= `NopInst;
		end else if((stall[1] == `Stop && stall[2] == `NoStop) || flush == `Flush) begin
			id_pc   <= `ZeroWord;
			id_inst <= `NopInst;
		end else if(stall[1] == `NoStop) begin
			id_pc   <= if_pc;
			id_inst <= if_inst;
			// id_inst <= {if_inst[7:0], if_inst[15:8], if_inst[23:16], if_inst[31:24]};
		end
	end

endmodule