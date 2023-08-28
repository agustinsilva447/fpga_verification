`timescale 1ns / 1ps

class generator;  
  rand bit [3:0] a, b; //rand (with repetition) or randc (without repetition) 
  bit [3:0] y;
endclass
 
module tb;
  generator g;
  int i = 0;
  int status = 0;
  
  initial begin
    g = new();    
    for(i=0;i<10;i++) begin
      g.randomize();
      $display("Value of a :%0d and b: %0d", g.a,g.b);
      #10;
    end    
  end
endmodule