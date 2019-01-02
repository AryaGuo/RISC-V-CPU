`include "defines.v"

module mem_ctrl(

	input							rst,
	input							clk,

//from mem
	input [`MemOpBus]				mem_op_i,
	input [`MemAddrBus]				mem_addr_i,
	input [`RegBus]					mem_data_i,
	input [`MemSelBus]				mem_sel_i,
	input 							mem_extend_i,

//from pc_reg
	input [`InstAddrBus]			pc_i,
	input 							restart,

//from ram
	input [`DATA_WIDTH-1:0]			get_data_i,

//from cache
	input 							hit,
	input [`InstBus]				inst_i,
	input 							cache_done_i,

//to pc_reg
	output reg 						if_done,

//to id
	output reg[`InstBus]			inst_o,

//to mem
	output reg [`RegBus]			mem_get_data_o,
	output reg						mem_done,

//to ram
	output reg 						rw_o,
	output reg [`MemAddrBus]		addr_o,
	output reg [`DATA_WIDTH-1:0]	data_o,

//to cache
	output reg						cache_op_o
	
);

	reg[2:0] state;
	reg[2:0] nxt_state;
	reg[`MemAddrBus] base;
	reg doing;	//0: if, 1: mem

	reg[`DATA_WIDTH-1:0]	data_0;
	reg[`DATA_WIDTH-1:0]	data_1;
	reg[`DATA_WIDTH-1:0]	data_2;
	reg[`DATA_WIDTH-1:0]	data_3;

	localparam STATE_IDLE   = 0;
	localparam STATE_READ_1 = 1;
	localparam STATE_READ_2 = 2;
	localparam STATE_READ_3 = 3;
	localparam STATE_READ_4 = 4;
	localparam STATE_WRITE_1 = 5;
	localparam STATE_WRITE_2 = 6;
	localparam STATE_WRITE_3 = 7;

	always @(posedge clk or posedge rst) begin
		if(rst == `RstEnable) begin
			if_done        <= `Done;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Done;
			rw_o    	   <= `rw_Read;
			addr_o         <= `ZeroMemAddr;
			data_o         <= `ZeroWord;
			state		   <= STATE_IDLE;
			nxt_state	   <= STATE_IDLE;
		end else begin
			state		   <= nxt_state;
		end
	end

	always @(*) begin
		case (state) 
		STATE_IDLE: begin
			cache_op_o	   <= `rw_Read;
			case(mem_op_i)
				`MemRead: begin
					case(mem_sel_i)
						`MemSelWord: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Busy;
							rw_o    	   <= `rw_Read;
							addr_o         <= mem_addr_i + 3;
							data_o         <= `ZeroWord;
							nxt_state	   <= STATE_READ_4;
							base 		   <= mem_addr_i;
							doing		   <= 1;
						end
						`MemSelHalf: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Busy;
							rw_o    	   <= `rw_Read;
							addr_o         <= mem_addr_i + 1;
							data_o         <= `ZeroWord;
							nxt_state	   <= STATE_READ_2;
							base 		   <= mem_addr_i;
							doing		   <= 1;
						end
						`MemSelByte: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Busy;
							rw_o    	   <= `rw_Read;
							addr_o         <= mem_addr_i;
							data_o         <= `ZeroWord;
							nxt_state	   <= STATE_READ_1;
							base 		   <= mem_addr_i;
							doing		   <= 1;
						end
						default: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Busy;
							rw_o    	   <= `rw_Read;
							addr_o         <= `ZeroMemAddr;
							data_o         <= `ZeroWord;
							nxt_state	   <= STATE_IDLE;
							base 		   <= `ZeroWord;
							doing		   <= 1;
						end
					endcase
				end
				`MemWrite: begin
					// $display ("store %x to mem:%x", mem_data_i, mem_addr_i);
					case(mem_sel_i)
						`MemSelWord: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Busy;
							rw_o    	   <= `rw_Write;
							addr_o         <= mem_addr_i + 3;
							data_o         <= mem_data_i[31:24];
							nxt_state	   <= STATE_WRITE_3;
							base 		   <= mem_addr_i;
							doing		   <= 1;
						end
						`MemSelHalf: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Busy;
							rw_o    	   <= `rw_Write;
							addr_o         <= mem_addr_i + 1;
							data_o         <= mem_data_i[15:8];
							nxt_state	   <= STATE_WRITE_1;
							base 		   <= mem_addr_i;
							doing		   <= 1;
						end
						`MemSelByte: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Done;
							rw_o    	   <= `rw_Write;
							addr_o         <= mem_addr_i;
							data_o         <= mem_data_i[7:0];
							nxt_state	   <= STATE_IDLE;
							base 		   <= mem_addr_i;
							doing		   <= 1;
						end
						default: begin
							if_done        <= `Busy;
							inst_o         <= `NopInst;
							mem_get_data_o <= `ZeroWord;
							mem_done       <= `Busy;
							rw_o    	   <= `rw_Read;
							addr_o         <= `ZeroMemAddr;
							data_o         <= `ZeroWord;
							nxt_state	   <= STATE_IDLE;
							base 		   <= `ZeroWord;
							doing		   <= 0;
						end
					endcase
				end
				`MemDisable: begin
					if_done        <= `Busy;
					inst_o         <= `NopInst;
					mem_get_data_o <= `ZeroWord;
					mem_done       <= `Busy;
					rw_o    	   <= `rw_Read;
					addr_o         <= pc_i + 3;
					data_o         <= `ZeroWord;
					nxt_state	   <= STATE_READ_4;
					base 		   <= pc_i;
					doing		   <= 0;
				end
			endcase
		end
		STATE_READ_4: 
		if(restart && doing == 0) begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o         <= pc_i + 3;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_READ_4;
			base 		   <= pc_i;
			doing		   <= 0;
		end else if(doing == 0 && hit) begin
			// $display("%d", inst_o);
			if_done        <= `Done;
			inst_o         <= inst_i;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o		   <= `ZeroMemAddr;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_IDLE;
		end else begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o         <= base + 2;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_READ_3;
			data_3		   <= get_data_i;
		end
		STATE_READ_3: 
		if(restart && doing == 0) begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o         <= pc_i + 3;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_READ_4;
			base 		   <= pc_i;
			doing		   <= 0;
		end else begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o         <= base + 1;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_READ_2;
			data_2		   <= get_data_i;
		end
		STATE_READ_2: 
		if(restart && doing == 0) begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o         <= pc_i + 3;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_READ_4;
			base 		   <= pc_i;
			doing		   <= 0;
		end else begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o         <= base;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_READ_1;
			data_1		   <= get_data_i;
		end
		STATE_READ_1: 
		if(restart && doing == 0) begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Read;
			addr_o         <= pc_i + 3;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_READ_4;
			base 		   <= pc_i;
			doing		   <= 0;
		end else begin
			rw_o    	   <= `rw_Read;
			addr_o		   <= `ZeroMemAddr;
			data_o         <= `ZeroWord;
			nxt_state	   <= STATE_IDLE;
			data_0		   <= get_data_i;
			case (doing)
				0: begin
					if_done        <= `Done;
					mem_done       <= `Busy;
					inst_o         <= {data_3, data_2, data_1, data_0};
					mem_get_data_o <= `ZeroWord;
					cache_op_o	   <= `rw_Write;
				end
				1: begin
					if_done        <= `Busy;
					mem_done       <= `Done;
					inst_o         <= `NopInst;
					cache_op_o	   <= `rw_Read;
					case (mem_sel_i)
						`MemSelWord: begin
							mem_get_data_o <= {data_3, data_2, data_1, data_0};
							// $display ("read mem[%x] = %x", mem_addr_i, mem_get_data_o);
						end
						`MemSelHalf: begin
							if(mem_extend_i == `UEXT) 
								mem_get_data_o <= {16'b0, data_1, data_0};
							else
								mem_get_data_o <= {{16{data_1[7]}}, data_1, data_0};
							// $display ("read mem[%x] = %x", mem_addr_i, mem_get_data_o);
							// $display ("Read half: mem[%x] = %x", mem_addr_i, mem_get_data_o);
						end
						`MemSelByte: begin
							if(mem_extend_i == `UEXT) 
								mem_get_data_o <= {24'b0, data_0};
							else
								mem_get_data_o <= {{24{data_0[7]}}, data_0};
							// $display ("read mem[%x] = %x", mem_addr_i, mem_get_data_o);
							// $display ("Read byte: mem[%x] = %x", mem_addr_i, mem_get_data_o);
						end
					endcase
				end
			endcase
		end
		STATE_WRITE_3: begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Write;
			addr_o         <= base + 2;
			data_o         <= mem_data_i[23:16];
			nxt_state	   <= STATE_WRITE_2;
		end
		STATE_WRITE_2: begin
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Busy;
			rw_o    	   <= `rw_Write;
			addr_o         <= base + 1;
			data_o         <= mem_data_i[15:8];
			nxt_state	   <= STATE_WRITE_1;
		end
		STATE_WRITE_1: begin
			// $display ("store %x to mem:%x", mem_data_i, mem_addr_i);
			if_done        <= `Busy;
			inst_o         <= `NopInst;
			mem_get_data_o <= `ZeroWord;
			mem_done       <= `Done;
			rw_o    	   <= `rw_Write;
			addr_o         <= base;
			data_o         <= mem_data_i[7:0];
			nxt_state	   <= STATE_IDLE;
		end
	endcase
	end

endmodule