`timescale 1ns / 1ps
 
module tb3();

    reg resetn;
    reg clk;
    
  initial begin
    clk = 1'b0;
    resetn = 1'b0;
    #60;
    resetn = 1'b1;
  end;
  
  initial begin
    #200;
    $finish();
  end

endmodule