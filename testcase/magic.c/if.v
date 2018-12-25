`include "defines.v"

module If(

	input						rst,

	input [`InstAddrBus]		pc_i,
	input [`InstBus]			inst_i,
	input						done,

	output reg[`InstAddrBus]	pc_o,
	output reg[`InstBus]		inst_o,
	output reg					stall_req
	
);

	always @ (*) begin
		if (rst == `RstEnable) begin
			pc_o      <= `ZeroWord;
			inst_o    <= `NopInst;
			stall_req <= `NoStop;
		end else begin
			pc_o      <= pc_i;
			inst_o	  <= inst_i;
			stall_req <= done == `Busy ? `Stop : `NoStop;
		end
	end

endmodule