`include "defines.v"

module id(

	input						rst,

	input [`InstAddrBus]		pc_i,
	input [`InstBus]			inst_i,

// from regfile
	input [`RegBus]				reg1_data_i,
	input [`RegBus]				reg2_data_i,

// forwarding
	input [`RegBus]				ex_wdata_i,
	input [`RegAddrBus]			ex_wd_i,
	input	 					ex_wreg_i,
	input [`RegBus]				mem_wdata_i,
	input [`RegAddrBus]			mem_wd_i,
	input	 					mem_wreg_i,

// to regfile
	output reg					reg1_read_o,
	output reg					reg2_read_o,
	output reg[`RegAddrBus]		reg1_addr_o,
	output reg[`RegAddrBus]		reg2_addr_o,
	
// to id/ex
	output reg[`OpcodeBus]		op_o,
	output reg[`Fun3Bus]		fun3_o,
	output reg[`Fun7Bus]		fun7_o,

	output reg[`RegBus]			reg1_o,
	output reg[`RegBus]			reg2_o,
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,
	output reg[`RegBus]			base_o,
	output reg[`RegBus]			offset_o

);

	wire[`OpcodeBus] 	opcode	=      inst_i[6:2];
	wire[`RegAddrBus] 	rd 		=      inst_i[11:7];
	wire[`Fun3Bus] 		f3		=      inst_i[14:12];
	wire[`RegAddrBus] 	rs1 	=      inst_i[19:15];
	wire[`RegAddrBus] 	rs2 	=      inst_i[24:20];
	wire[`Fun7Bus] 		f7  	=      inst_i[30];
	wire 				valid   =	   inst_i[0];

	reg[`RegBus] imm = `ZeroWord;

	always @(*) begin
		if (rst == `RstEnable || !valid) begin
			reg1_read_o		<= `ReadDisable;
			reg2_read_o		<= `ReadDisable;
			reg1_addr_o		<= `NOPRegAddr;
			reg2_addr_o		<= `NOPRegAddr;

			op_o			<= `OP_NOP;
			fun3_o			<= `FUN3_NOP;
			fun7_o			<= `FUN7_NOP;
			wd_o			<= `NOPRegAddr;
			wreg_o			<= `WriteDisable;
			base_o			<= `ZeroWord;
			offset_o		<= `ZeroWord;
			imm				<= `ZeroWord;
		end else begin
			case (opcode)
				`OP_REG_IM: begin
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadDisable;
					reg1_addr_o <= rs1;
					reg2_addr_o <= `NOPRegAddr;
					op_o		<= opcode;
					fun3_o      <= f3;
					fun7_o      <= `FUN7_NOP;
					wd_o        <= rd;
					wreg_o      <= `WriteEnable;
					base_o      <= `ZeroWord;
					offset_o    <= `ZeroWord;
					imm 		<= `ZeroWord;
					case (f3)
						`FUN3_ADDI: 
							imm <= {{20{inst_i[31]}}, inst_i[31:20]};	//sign-extend
						`FUN3_SLT:
							imm <= {{20{inst_i[31]}}, inst_i[31:20]};
						`FUN3_SLLI:
							imm <= {27'b0, inst_i[24:20]};				//unsign-extend
						`FUN3_SRLI_SRAI:
							imm <= {27'b0, inst_i[24:20]};
						default:
							imm <= {20'b0, inst_i[31:20]};				//unsign-extend
					endcase
				end
				`OP_REG_REG: begin
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadEnable;
					reg1_addr_o <= rs1;
					reg2_addr_o <= rs2;
					op_o		<= opcode;
					fun3_o      <= f3;
					fun7_o      <= f7;
					wd_o        <= rd;
					wreg_o      <= `WriteEnable;
					base_o      <= `ZeroWord;
					offset_o    <= `ZeroWord;
					imm 		<= `ZeroWord;
				end
				`OP_LUI: begin
					reg1_read_o <= `ReadDisable;
					reg2_read_o <= `ReadDisable;
					reg1_addr_o <= `NOPRegAddr;
					reg2_addr_o <= `NOPRegAddr;
					op_o		<= opcode;
					fun3_o      <= `FUN3_NOP;
					fun7_o      <= `FUN7_NOP;
					wd_o        <= rd;
					wreg_o      <= `WriteEnable;
					base_o      <= `ZeroWord;
					offset_o    <= `ZeroWord;
					imm			<= {inst_i[31:12], 12'b0};
				end
				`OP_AUIPC: begin
					reg1_read_o <= `ReadDisable;
					reg2_read_o <= `ReadDisable;
					reg1_addr_o <= `NOPRegAddr;
					reg2_addr_o <= `NOPRegAddr;
					op_o		<= opcode;
					fun3_o      <= `FUN3_NOP;
					fun7_o      <= `FUN7_NOP;
					wd_o        <= rd;
					wreg_o      <= `WriteEnable;
					base_o      <= `ZeroWord;
					offset_o    <= `ZeroWord;
					imm			<= {inst_i[31:12], 12'b0};
				end
				`OP_JAL: begin
					reg1_read_o <= `ReadDisable;
					reg2_read_o <= `ReadDisable;
					reg1_addr_o <= `NOPRegAddr;
					reg2_addr_o <= `NOPRegAddr;
					op_o		<= opcode;
					fun3_o      <= `FUN3_NOP;
					fun7_o      <= `FUN7_NOP;
					wd_o        <= rd;
					wreg_o      <= `WriteEnable;
					base_o      <= pc_i;
					offset_o    <= {{11{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
					imm		    <= 4;
				end
				`OP_JALR: begin
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadDisable;
					reg1_addr_o <= rs1;
					reg2_addr_o <= `NOPRegAddr;
					op_o		<= opcode;
					fun3_o      <= `FUN3_NOP;
					fun7_o      <= `FUN7_NOP;
					wd_o        <= rd;
					wreg_o      <= `WriteEnable;
					offset_o	<= {{20{inst_i[31]}}, inst_i[31:20]};
					imm         <= 4;
				end
				`OP_BRANCH: begin
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadEnable;
					reg1_addr_o <= rs1;
					reg2_addr_o <= rs2;
					op_o		<= opcode;
					fun3_o      <= f3;
					fun7_o      <= `FUN7_NOP;
					wd_o        <= `NOPRegAddr;
					wreg_o      <= `WriteDisable;
					base_o      <= pc_i;
					offset_o	<= {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
					imm			<= `ZeroWord;
				end
				`OP_LOAD: begin
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadDisable;
					reg1_addr_o <= rs1;
					reg2_addr_o <= `NOPRegAddr;
					op_o		<= opcode;
					fun3_o 		<= f3;
					fun7_o      <= `FUN7_NOP;
					wd_o		<= rd;
					wreg_o		<= `WriteEnable;
					offset_o	<= {{20{inst_i[31]}}, inst_i[31:20]};
					imm			<= `ZeroWord;
				end
				`OP_STORE: begin
					reg1_read_o <= `ReadEnable;
					reg2_read_o <= `ReadEnable;
					reg1_addr_o <= rs1;
					reg2_addr_o <= rs2;
					op_o		<= opcode;
					fun3_o 		<= f3;
					fun7_o      <= `FUN7_NOP;
					wd_o        <= `NOPRegAddr;
					wreg_o      <= `WriteDisable;
					offset_o	<= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
					imm			<= `ZeroWord;
				end
				default: begin
					reg1_read_o		<= `ReadDisable;
					reg2_read_o		<= `ReadDisable;
					reg1_addr_o		<= `NOPRegAddr;
					reg2_addr_o		<= `NOPRegAddr;
					op_o			<= `OP_NOP;
					fun3_o			<= `FUN3_NOP;
					fun7_o			<= `FUN7_NOP;
					wd_o			<= `NOPRegAddr;
					wreg_o			<= `WriteDisable;
					base_o			<= `ZeroWord;
					offset_o		<= `ZeroWord;
					imm				<= `ZeroWord;
				end
			endcase
		end
	end

// determine reg1
	always @(*) begin
		if (rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
		end else if (reg1_read_o == `ReadEnable && ex_wreg_i == `WriteEnable && ex_wd_i == reg1_addr_o) begin
			reg1_o <= ex_wdata_i;
		end else if (reg1_read_o == `ReadEnable && mem_wreg_i == `WriteEnable && mem_wd_i == reg1_addr_o) begin
			reg1_o <= mem_wdata_i;
		end else if (opcode == `OP_AUIPC || opcode == `OP_JAL || opcode == `OP_JALR) begin
			reg1_o <= pc_i;
		end else if (reg1_read_o == `ReadEnable) begin			//jalr not included
			reg1_o <= reg1_data_i;
		end else begin
			reg1_o <= imm;
		end
		if (opcode == `OP_JALR || opcode == `OP_LOAD || opcode == `OP_STORE) begin
			if (rst == `RstEnable) begin
				base_o <= `ZeroWord;
			end else if (ex_wreg_i == `WriteEnable && ex_wd_i == reg1_addr_o) begin
				base_o <= ex_wdata_i;
			end else if (mem_wreg_i == `WriteEnable && mem_wd_i == reg1_addr_o) begin
				base_o <= mem_wdata_i;
			end else begin
				base_o <= reg1_data_i;
			end
		end
	end
 
// determine reg2
 	always @(*) begin
		if (rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
		end else if (reg2_read_o == `ReadEnable && ex_wreg_i == `WriteEnable && ex_wd_i == reg2_addr_o) begin
			reg2_o <= ex_wdata_i;
		end else if (reg2_read_o == `ReadEnable && mem_wreg_i == `WriteEnable && mem_wd_i == reg2_addr_o) begin
			reg2_o <= mem_wdata_i;
		end else if (reg2_read_o == `ReadEnable) begin
			reg2_o <= reg2_data_i;
		end else begin
			reg2_o <= imm;
		end
	end

endmodule