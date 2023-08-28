`timescale 1ns / 1ps
 
module tb4();  
  reg rst;
  reg clk; //initial value = X
  reg clk25 = 0;  ///initialize variable
  reg clk50;
  
  initial begin
    rst = 1'b0;
    clk = 1'b0;
    clk50 = 0;    
    #40; 
    rst = 1'b1;
  end 
  
  always #5  clk   = ~clk;       //100 MHz  
  always #10 clk50 = ~clk50;  ///50 MHz  
  always #20 clk25 = ~clk25;  ///25 MHz
   
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end 
 
  initial begin
    #200;
    $finish();
  end
  
endmodule
