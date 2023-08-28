`timescale 1ns / 1ps

class generator;
  randc bit [3:0] a, b; ////////////rand or randc 
  bit [3:0] y;
  /*
  constraint data_a {a > 3; a < 7;}  
  constraint data_b {b == 3;}
  */  
  constraint data {a > 3; a < 7 ; b > 0;}
endclass
 
module tb4;
  generator g;
  int i = 0;
  int status = 0;
  
  initial begin
    for(i=0;i<10;i++) begin
      g = new();
      g.randomize();
      $display("Value of a :%0d and b: %0d", g.a,g.b);
      #10;
    end    
  end  
endmodule