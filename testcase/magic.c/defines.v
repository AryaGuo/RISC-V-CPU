`ifndef _DEFINES_V_
	`define _DEFINES_V_
	
	`define RstEnable 		1'b1
	`define RstDisable 		1'b0
	`define ZeroWord 		32'h00000000
	`define WriteEnable		1'b1
	`define WriteDisable 	1'b0
	`define ReadEnable 		1'b1
	`define ReadDisable 	1'b0

	`define MemOpBus	1:0
	`define MemRead 	2'b11
	`define MemWrite 	2'b10
	`define MemDisable	2'b00

	`define OpcodeBus	4:0
	`define Fun3Bus 	2:0
	`define Fun7Bus 	0:0

	`define Stop 		1'b1
	`define NoStop 		1'b0
	`define Branch 		1'b1
	`define NotBranch 	1'b0
	`define Flush 		1'b1
	`define NoFlush 	1'b0
	`define Busy 		1'b0
	`define Done 		1'b1
	`define rw_Read  	1'b0
	`define rw_Write 	1'b1

	`define ChipEnable 	1'b1
	`define ChipDisable 1'b0

	`define OP_REG_IM  	5'b00100
	`define OP_REG_REG	5'b01100
	`define OP_LOAD		5'b00000
	`define OP_STORE	5'b01000
	`define OP_BRANCH	5'b11000
	`define OP_JAL		5'b11011
	`define OP_JALR		5'b11001
	`define OP_LUI		5'b01101
	`define OP_AUIPC	5'b00101
	`define OP_NOP 		5'b11111

	`define FUN3_ADDI		3'b000
	`define FUN3_SLTI		3'b010
	`define FUN3_SLTIU		3'b011
	`define FUN3_XORI		3'b100
	`define FUN3_ORI    	3'b110
	`define FUN3_ANDI		3'b111
	`define FUN3_SLLI		3'b001
	`define FUN3_SRLI_SRAI	3'b101

	`define FUN3_ADD_SUB	3'b000
	`define FUN3_SLL		3'b001
	`define FUN3_SLT		3'b010
	`define FUN3_SLTU		3'b011
	`define FUN3_XOR		3'b100
	`define FUN3_SRL_SRA	3'b101
	`define FUN3_OR  	  	3'b110
	`define FUN3_AND		3'b111

	`define FUN3_BEQ		3'b000
	`define FUN3_BNE		3'b001
	`define FUN3_BLT		3'b100
	`define FUN3_BGE		3'b101
	`define FUN3_BLTU		3'b110
	`define FUN3_BGEU		3'b111

	`define FUN3_NOP  		3'b000

	`define FUN7_SRLI	1'b0
	`define FUN7_SRAI	1'b1
	`define FUN7_SRL	1'b0
	`define FUN7_SRA	1'b1
	`define FUN7_ADD	1'b0
	`define FUN7_SUB	1'b1

	`define FUN7_NOP	1'b0

	`define StallBus	5:0

	`define InstAddrBus 	31:0
	`define InstBus 		31:0
	`define InstMemNum 		131071
	`define InstMemNumLog2	17
	`define NopInst			32'hffffffff

	`define RegAddrBus 	4:0
	`define RegBus 		31:0
	`define RegNum 		32
	`define RegNumLog2 	5
	`define NOPRegAddr 	5'b00000

	`define ADDR_WIDTH  17
	`define DATA_WIDTH  8
	`define ZeroMemAddr 17'b0
	`define MemAddrBus 	31:0

	`define MemSelBus   1:0
	`define MemSelWord  2'b11
	`define MemSelHalf  2'b10
	`define MemSelByte  2'b01
	`define MemSelEmpty 2'b00

	`define SEXT	1'b1
	`define UEXT	1'b0

`endif