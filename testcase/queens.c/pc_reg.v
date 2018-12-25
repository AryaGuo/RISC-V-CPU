`include "defines.v"

module pc_reg(

	input						clk,
	input						rst,

	input [`StallBus]			stall,

	input [`InstAddrBus]		branch_addr_i,
	input						branch_taken_i,
	
	output reg[`InstAddrBus]	pc,
	output reg 					ce,
	output reg					restart
	
);

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc      <= `ZeroWord;
			restart <= 0;
		end else if (branch_taken_i == `Branch) begin
			pc      <= branch_addr_i;
			restart <= 1;
		end else if(stall[0] == `NoStop) begin
	        pc      <= pc + 4;
			restart <= 1;
		end else begin
			restart <= 0;
		end
	end
	
	always @ (posedge clk or posedge rst) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule