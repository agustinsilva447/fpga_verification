`timescale 1ns / 1ps

class generator;
  rand bit rst;
  rand bit wr;
  
  constraint cntrl {   
    rst dist {0 := 30 , 1 := 70};  
    wr  dist {0 := 50 , 1 := 50};   
  }  
endclass
 
module tb11();
  generator f;  
  initial begin
    f = new();    
    for(int i = 0; i < 20; i++) begin
      f.randomize();
      $display("Value of Rst : %0d and wr : %0d", f.rst, f.wr);    
    end    
  end
endmodule