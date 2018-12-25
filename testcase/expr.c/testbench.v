// testbench top module file
// for simulation only

`timescale 1ns/1ps

`include "riscv_top.v"
module testbench;

reg clk;
reg rst;

riscv_top #(.SIM(1)) top(
    .EXCLK(clk),
    .btnC(rst),
    .Tx(),
    .Rx(),
    .led()
);

initial begin
  $dumpfile("main.vcd");
  $dumpvars;
  clk=0;
  rst=1;
  repeat(10) #1 clk=!clk;
  rst=0; 
  forever #1 clk=!clk;
  // repeat(100000) #1 clk=!clk;
  $finish;
end

endmodule