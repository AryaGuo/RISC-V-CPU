`include "defines.v"

module ctrl(

	input					rst,
	input					rdy_in,
	input					stall_req_if,
	input					stall_req_mem,
	input					flush_req,

	// 0~5 for pc/if/id/ex/mem/wb
	output reg[`StallBus]	stall,
	output reg 				flush
	
);

	always @(*) begin
		if (rst == `RstEnable) begin
			stall <= 6'b000000;
		end else if(!rdy_in) begin
			stall <= 6'b111111;
		end else if (stall_req_mem == `Stop) begin
			stall <= 6'b011111;
		end else if (stall_req_if == `Stop) begin
			stall <= 6'b000011;
		end else begin
			stall <= 6'b000000;
		end
	end
	always @(*) begin
		if (rst == `RstEnable) begin
			flush <= `NoFlush;
		end else begin
			flush <= flush_req;
		end
	end

endmodule