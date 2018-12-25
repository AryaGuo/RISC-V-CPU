`include "defines.v"

module ex(

	input wire					rst,

	input [`OpcodeBus]			op_i,
	input [`Fun3Bus]			fun3_i,
	input [`Fun7Bus]			fun7_i,
	input [`RegBus]				reg1_i,
	input [`RegBus]				reg2_i,
	input [`RegAddrBus]			wd_i,
	input 						wreg_i,
	input [`RegBus]				base_i,
	input [`RegBus]				offset_i,
	
	output reg[`RegBus]			wdata_o,
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,

	output reg [`MemOpBus]		me_op_o,
	output reg [`MemAddrBus]	me_addr_o,
	output reg [`RegBus]		me_data_o,
	output reg [`MemSelBus]     me_sel_o,
	output reg 					me_extend_o,

// to pc_reg
	output reg					branch_taken_o,
	output reg[`InstAddrBus]	branch_addr_o

);

	reg[`RegBus] reg_im;
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg_im <= `ZeroWord;
		end else if (op_i == `OP_REG_IM) begin
			case (fun3_i)
				`FUN3_ADDI:		reg_im <= reg1_i + reg2_i;
				`FUN3_SLTI:		reg_im <= $signed(reg1_i) < $signed(reg2_i) ? 1 : 0;
				`FUN3_SLTIU:	reg_im <= reg1_i < reg2_i ? 1 : 0;
				`FUN3_XORI:		reg_im <= reg1_i ^ reg2_i;
				`FUN3_ORI:		reg_im <= reg1_i | reg2_i;
				`FUN3_ANDI:		reg_im <= reg1_i & reg2_i;
				`FUN3_SLLI:		reg_im <= reg1_i << reg2_i;
				`FUN3_SRLI_SRAI: begin
					case (fun7_i)
						`FUN7_SRLI:		reg_im <= reg1_i >> reg2_i;
						`FUN7_SRAI:		reg_im <= $signed(reg1_i) >>> reg2_i;
						default: 		reg_im <= `ZeroWord;
					endcase
				end
				default: 		reg_im <= `ZeroWord;
			endcase
		end
	end

	reg[`RegBus] reg_reg;
	always @(*) begin
		if (rst == `RstEnable) begin
			reg_reg <= `ZeroWord;
		end else if (op_i == `OP_REG_REG) begin
			case (fun3_i)
				`FUN3_ADD_SUB: begin
					case (fun7_i)
						`FUN7_ADD: reg_reg <= reg1_i + reg2_i;
						`FUN7_SUB: reg_reg <= reg1_i - reg2_i;
						default: reg_reg <= `ZeroWord;
					endcase
				end
				`FUN3_SLL:		reg_reg <= reg1_i << reg2_i;
				`FUN3_SLT:		reg_reg <= $signed(reg1_i) < $signed(reg2_i) ? 1 : 0;
				`FUN3_SLTU:		reg_reg <= reg1_i < reg2_i ? 1 : 0;
				`FUN3_XOR:		reg_reg <= reg1_i ^ reg2_i;
				`FUN3_OR:		reg_reg <= reg1_i | reg2_i;
				`FUN3_AND:		reg_reg <= reg1_i & reg2_i;
				`FUN3_SRL_SRA: begin
					case (fun7_i)
						`FUN7_SRL:		reg_reg <= reg1_i >> reg2_i;
						`FUN7_SRA:		reg_reg <= $signed(reg1_i) >>> reg2_i;
						default: 		reg_reg <= `ZeroWord;
					endcase
				end
			endcase
		end
	end

	always @(*) begin
		if(rst == `RstEnable) begin
			wdata_o        <= `ZeroWord;
			wd_o		   <= `NOPRegAddr;
			wreg_o		   <= `WriteDisable;
			branch_taken_o <= `NotBranch;
			branch_addr_o  <= `ZeroWord;
			me_op_o		   <= `MemDisable;
			me_addr_o	   <= `ZeroMemAddr;
			me_data_o	   <= `ZeroWord;
			me_sel_o	   <= `MemSelEmpty;
			me_extend_o	   <= `SEXT;
		end else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			case (op_i)
				`OP_REG_IM:	begin
					wdata_o        <= reg_im;
					branch_taken_o <= `NotBranch;
					branch_addr_o  <= `ZeroWord;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
				end	
				`OP_REG_REG: begin
					wdata_o        <= reg_reg;
					branch_taken_o <= `NotBranch;
					branch_addr_o  <= `ZeroWord;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
				end
				`OP_LUI: begin
					wdata_o        <= reg1_i;
					branch_taken_o <= `NotBranch;
					branch_addr_o  <= `ZeroWord;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
				end	
				`OP_AUIPC: begin
					wdata_o        <= reg1_i + reg2_i;
					branch_taken_o <= `NotBranch;
					branch_addr_o  <= `ZeroWord;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
				end
				`OP_JAL: begin
					wdata_o        <= reg1_i + reg2_i;
					branch_taken_o <= `Branch;
					branch_addr_o  <= base_i + offset_i;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
				end
				`OP_JALR: begin
					wdata_o        <= reg1_i + reg2_i;
					branch_taken_o <= `Branch;
					branch_addr_o  <= base_i + offset_i;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
				end
				`OP_BRANCH: begin
					wdata_o        <= `ZeroWord;
					branch_addr_o  <= base_i + offset_i;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
					case (fun3_i)
						`FUN3_BEQ:	branch_taken_o <= reg1_i == reg2_i ? `Branch : `NotBranch;
						`FUN3_BNE:	branch_taken_o <= reg1_i != reg2_i ? `Branch : `NotBranch;
						`FUN3_BLT:	branch_taken_o <= $signed(reg1_i) < $signed(reg2_i) ? `Branch : `NotBranch;
						`FUN3_BGE:	branch_taken_o <= $signed(reg1_i) >= $signed(reg2_i) ? `Branch : `NotBranch;
						`FUN3_BLTU:	branch_taken_o <= reg1_i < reg2_i ? `Branch : `NotBranch;
						`FUN3_BGEU:	branch_taken_o <= reg1_i >= reg2_i ? `Branch : `NotBranch;
						default:	branch_taken_o <= `NotBranch;
					endcase
				end
				`OP_LOAD: begin
					wdata_o		   <= `ZeroWord;
					branch_taken_o <= `NotBranch;
					branch_addr_o  <= `ZeroWord;
					me_op_o		   <= `MemRead;
					me_addr_o	   <= base_i + offset_i;
					me_data_o	   <= `ZeroWord;
					me_extend_o	   <= fun3_i[2] ? `UEXT : `SEXT;
					if(fun3_i[1]) 		me_sel_o   <= `MemSelWord;
					else if(fun3_i[0])  me_sel_o   <= `MemSelHalf;
					else 				me_sel_o   <= `MemSelByte;
				end
				`OP_STORE: begin
					wdata_o		   <= `ZeroWord;
					branch_taken_o <= `NotBranch;
					branch_addr_o  <= `ZeroWord;
					me_op_o		   <= `MemWrite;
					me_addr_o	   <= base_i + offset_i;
					me_data_o	   <= reg2_i;
					me_extend_o	   <= `SEXT;
					if(fun3_i[1]) 		me_sel_o   <= `MemSelWord;
					else if(fun3_i[0])  me_sel_o   <= `MemSelHalf;
					else 				me_sel_o   <= `MemSelByte;
				end
				default: begin
					wdata_o        <= `ZeroWord;
					branch_taken_o <= `NotBranch;
					branch_addr_o  <= `ZeroWord;
					me_op_o		   <= `MemDisable;
					me_addr_o	   <= `ZeroMemAddr;
					me_data_o	   <= `ZeroWord;
					me_sel_o	   <= `MemSelEmpty;
					me_extend_o	   <= `SEXT;
				end
			endcase
		end
	end

endmodule