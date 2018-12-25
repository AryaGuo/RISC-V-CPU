`include "pc_reg.v"
`include "if.v"
`include "if_id.v"
`include "id.v"
`include "regfile.v"
`include "id_ex.v"
`include "ex.v"
`include "ex_mem.v"
`include "mem.v"
`include "mem_wb.v"
`include "ctrl.v"
`include "mem_ctrl.v"

module cpu(

	input						clk_in,
	input						rst_in,
	input						rdy_in,
	
	output						ce,
	output                   	mem_wr,  
 	output [`MemAddrBus] 		mem_a,    
 	output [`DATA_WIDTH-1:0]    mem_dout, 
  	input  [`DATA_WIDTH-1:0]   	mem_din
	
);

	wire [`InstAddrBus] 		pc;
	wire [`InstAddrBus]			branch_addr;
	wire						branch_taken;
	wire						restart;

	wire						stall_req_if;
	wire						stall_req_mem;
	wire [`StallBus]			stall;
	wire 						flush;

	wire						if_done;
	wire [`InstBus]				if_inst_i;
	wire [`InstAddrBus] 		if_pc_o;
	wire [`InstBus]				if_inst_o;

	wire [`InstAddrBus] 		id_pc_i;
	wire [`InstBus]				id_inst_i;
	
	wire [`OpcodeBus] 			id_op_o;
	wire [`Fun3Bus]				id_fun3_o;
	wire [`Fun7Bus]				id_fun7_o;
	wire [`RegBus] 				id_reg1_o;
	wire [`RegBus] 				id_reg2_o;
	wire 						id_wreg_o;
	wire [`RegAddrBus] 			id_wd_o;
	wire [`RegBus]				id_base_o;
	wire [`RegBus]				id_offset_o;
	
	wire [`OpcodeBus] 			ex_op_i;
	wire [`Fun3Bus] 			ex_fun3_i;
	wire [`Fun7Bus] 			ex_fun7_i;
	wire [`RegBus] 				ex_reg1_i;
	wire [`RegBus]				ex_reg2_i;
	wire 						ex_wreg_i;
	wire [`RegAddrBus] 			ex_wd_i;
	wire [`RegBus]				ex_base_i;
	wire [`RegBus]				ex_offset_i;
	
	wire 						ex_wreg_o;
	wire [`RegAddrBus] 			ex_wd_o;
	wire [`RegBus] 				ex_wdata_o;
	wire [`MemOpBus]			ex_op_o;
	wire [`MemAddrBus]			ex_addr_o;
	wire [`RegBus]				ex_data_o;
	wire [`MemSelBus]     		ex_sel_o;
	wire 						ex_extend_o;

	wire 						mem_wreg_i;
	wire [`RegAddrBus]			mem_wd_i;
	wire [`RegBus] 				mem_wdata_i;
	wire [`MemOpBus]			mem_op_i;
	wire [`MemAddrBus]			mem_addr_i;
	wire [`RegBus]				mem_data_i;
	wire [`MemSelBus]			mem_sel_i;
	wire						mem_extend_i;

	wire						mem_done;
	wire [`RegBus]				mem_get_data;

	wire 						mem_wreg_o;
	wire [`RegAddrBus] 			mem_wd_o;
	wire [`RegBus] 				mem_wdata_o;
	wire [`MemOpBus]			mem_op_o;
	wire [`MemAddrBus]			mem_addr_o;
	wire [`RegBus]				mem_data_o;
	wire [`MemSelBus]			mem_sel_o;
	wire						mem_extend_o;
	
	wire 						wb_wreg_i;
	wire [`RegAddrBus] 			wb_wd_i;
	wire [`RegBus] 				wb_wdata_i;
	
	wire 						reg1_read;
	wire 						reg2_read;
	wire [`RegBus] 				reg1_data;
	wire [`RegBus] 				reg2_data;
	wire [`RegAddrBus]			reg1_addr;
	wire [`RegAddrBus]			reg2_addr;
  
	pc_reg pc_reg0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),
		.pc(pc),
		.ce(ce),
		.restart(restart),
		.branch_addr_i(branch_addr),
		.branch_taken_i(branch_taken)
	);
	
	// assign rom_addr_o = pc;

	If if0(
		.rst       (rst_in),
		.pc_i      (pc),
		.inst_i    (if_inst_i),
		.done      (if_done),
		.pc_o      (if_pc_o),
		.inst_o    (if_inst_o),
		.stall_req (stall_req_if)
	);

	if_id if_id0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),
		.flush(flush),
		.if_pc(if_pc_o),
		.if_inst(if_inst_o),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);

	id id0(
		.rst(rst_in),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read),
		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr),
	
		.op_o(id_op_o),
		.fun3_o(id_fun3_o),
		.fun7_o(id_fun7_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.base_o(id_base_o),
		.offset_o(id_offset_o),

		.ex_wdata_i  (ex_wdata_o),
		.ex_wd_i     (ex_wd_o),
		.ex_wreg_i   (ex_wreg_o),
		.mem_wdata_i (mem_wdata_o),
		.mem_wd_i    (mem_wd_o),
		.mem_wreg_i  (mem_wreg_o)

	);

	regfile regfile1(
		.clk(clk_in),
		.rst(rst_in),

		.we(wb_wreg_i),
		.wr_addr(wb_wd_i),
		.wr_data(wb_wdata_i),

		.re_0(reg1_read),
		.rd_addr_0(reg1_addr),
		.rd_data_0(reg1_data),
		.re_1(reg2_read),
		.rd_addr_1(reg2_addr),
		.rd_data_1(reg2_data)
	);

	id_ex id_ex0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),
		.flush(flush),
		
		.id_op(id_op_o),
		.id_fun3(id_fun3_o),
		.id_fun7(id_fun7_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.id_base(id_base_o),
		.id_offset(id_offset_o),

		.ex_op(ex_op_i),
		.ex_fun3(ex_fun3_i),
		.ex_fun7(ex_fun7_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_base(ex_base_i),
		.ex_offset(ex_offset_i)
	);		
	
	ex ex0(
		.rst(rst_in),
	
		.op_i(ex_op_i),
		.fun3_i(ex_fun3_i),
		.fun7_i(ex_fun7_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
		.base_i(ex_base_i),
		.offset_i(ex_offset_i),
	  
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),

		.me_op_o        (ex_op_o),
		.me_addr_o      (ex_addr_o),
		.me_data_o      (ex_data_o),
		.me_sel_o       (ex_sel_o),
		.me_extend_o    (ex_extend_o),
		.branch_addr_o(branch_addr),
		.branch_taken_o(branch_taken)
		
	);

	ex_mem ex_mem0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),
	  
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.ex_me_op      (ex_op_o),
		.ex_me_addr    (ex_addr_o),
		.ex_me_data    (ex_data_o),
		.ex_me_sel     (ex_sel_o),
		.ex_me_extend  (ex_extend_o),	

		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.mem_me_op     (mem_op_i),
		.mem_me_addr   (mem_addr_i),
		.mem_me_data   (mem_data_i),
		.mem_me_sel    (mem_sel_i),
		.mem_me_extend (mem_extend_i)
	);

	mem mem0(
		.rst          (rst_in),
		.wdata_i      (mem_wdata_i),
		.wd_i         (mem_wd_i),
		.wreg_i       (mem_wreg_i),

		.mem_op_i     (mem_op_i),
		.mem_addr_i   (mem_addr_i),
		.mem_data_i   (mem_data_i),
		.mem_sel_i    (mem_sel_i),
		.mem_extend_i (mem_extend_i),

		.done         (mem_done),
		.get_data     (mem_get_data),
		.wdata_o      (mem_wdata_o),
		.wd_o         (mem_wd_o),
		.wreg_o       (mem_wreg_o),

		.mem_op_o     (mem_op_o),
		.mem_addr_o   (mem_addr_o),
		.mem_data_o   (mem_data_o),
		.mem_sel_o    (mem_sel_o),
		.mem_extend_o (mem_extend_o),

		.stall_req    (stall_req_mem)
	);


	mem_wb mem_wb0(
		.clk(clk_in),
		.rst(rst_in),
		.stall(stall),

		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
	
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)
									       	
	);

	ctrl ctrl0(
		.rst           (rst_in),
		.rdy_in		   (rdy_in),
		.stall_req_if  (stall_req_if),
		.stall_req_mem (stall_req_mem),
		.flush_req     (branch_taken),

		.stall         (stall),
		.flush         (flush)
	);

	mem_ctrl mem_ctrl0(
		.rst            (rst_in),
		.clk            (clk_in),
		.mem_op_i       (mem_op_o),
		.mem_addr_i     (mem_addr_o),
		.mem_data_i     (mem_data_o),
		.mem_sel_i      (mem_sel_o),
		.mem_extend_i   (mem_extend_o),
		.pc_i           (pc),
		.restart 		(restart),
		.get_data_i     (mem_din),
		.if_done        (if_done),
		.inst_o         (if_inst_i),
		.mem_get_data_o (mem_get_data),
		.mem_done       (mem_done),
		.rw_o        	(mem_wr),
		.addr_o         (mem_a),
		.data_o         (mem_dout)
	);

endmodule