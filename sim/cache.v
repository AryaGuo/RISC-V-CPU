`include "defines.v"

module cache(

	input							rst,
	input							clk,

	input							op_i,	//read:0, write:1
	input [`InstAddrBus]			addr_i,
	input [`InstBus]				data_i,

	output reg [`InstBus]			data_o,
	output reg						hit
	
);

	localparam IDX = 9;
	localparam TAG = 32-2-IDX;
	localparam SZ  = 1 << (IDX+1);

	`define ByteOffsetBus	 1:0
	`define IndexBus 	  	 IDX+1:2
	`define TagBus 	  		 31:IDX+2

	`define TagBit	33+TAG:34
	`define VBit	33
	`define LRUBit	32
	`define DataBit 31:0

	reg[33+TAG:0] data[0:SZ-1];


	wire[9:0] idx0;
	wire[9:0] idx1;
	wire[`TagBus] 	tag;

	assign idx0 = {1'b0, addr_i[`IndexBus]};
	assign idx1 = {1'b1, addr_i[`IndexBus]};
	assign tag = addr_i[`TagBus];

	integer i;
	
	always @(posedge rst or posedge clk) begin
		if (rst == `RstEnable) begin
			hit        <= 0;
			data_o     <= `NopInst;
			for (i = 0; i < 1024; i = i + 1)
				data[i] = 55'b0;
		end else begin
			case (op_i)
			`rw_Read: begin
				if(data[idx0][`VBit] && data[idx0][`TagBit] == tag) begin
				// $display("111 %x %x", addr_i, data[idx0][`DataBit]);
					hit                 <= 1;
					data_o              <= data[idx0][`DataBit];
					data[idx0][`LRUBit] <= 1;
					data[idx1][`LRUBit] <= 0;
				end else if(data[idx1][`VBit] && data[idx1][`TagBit] == tag) begin
				// $display("222 %x %x", addr_i, data[idx1][`DataBit]);
					hit                 <= 1;
					data_o              <= data[idx1][`DataBit];
					data[idx0][`LRUBit] <= 0;
					data[idx1][`LRUBit] <= 1;
				end else begin
				// $display(555, addr_i);
					hit                 <= 0;
					data_o              <= `NopInst;
				end
			end
			`rw_Write: begin
				hit    <= 0;
				data_o <= `NopInst;
				// $display("cache write %x %x", addr_i,data_i);
				// $display("%b %b",idx0,idx1);
				if(~data[idx0][`VBit]) begin
					data[idx0][`TagBit]  <= tag;
					data[idx0][`VBit]    <= 1;
					data[idx0][`LRUBit]  <= 1;
					data[idx1][`LRUBit]  <= 0;
					data[idx0][`DataBit] <= data_i;
				end else if(~data[idx1][`VBit]) begin
					data[idx1][`TagBit]  <= tag;
					data[idx1][`VBit]    <= 1;
					data[idx0][`LRUBit]  <= 0;
					data[idx1][`LRUBit]  <= 1;
					data[idx1][`DataBit] <= data_i;
				end else if(~data[idx0][`LRUBit]) begin
					data[idx0][`TagBit]  <= tag;
					data[idx0][`VBit]    <= 1;
					data[idx0][`LRUBit]  <= 1;
					data[idx1][`LRUBit]  <= 0;
					data[idx0][`DataBit] <= data_i;
				end else begin
					data[idx1][`TagBit]  <= tag;
					data[idx1][`VBit]    <= 1;
					data[idx0][`LRUBit]  <= 0;
					data[idx1][`LRUBit]  <= 1;
					data[idx1][`DataBit] <= data_i;
				end
			end
			endcase
		end
	end

	initial begin
		for (i = 0; i < 1024; i = i + 1)
			data[i] = 55'b0;
	end

endmodule