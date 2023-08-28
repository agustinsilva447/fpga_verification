`timescale 1ps / 1ps

module tb5();
  reg clk = 0; //initial value = X
  
  always #20000 clk = ~clk;
 
  initial begin
    #2000000;
    $finish();
  end
  
endmodule