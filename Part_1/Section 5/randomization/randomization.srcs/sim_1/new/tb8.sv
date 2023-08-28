`timescale 1ns / 1ps
//pre-randomize
//post-randomize
 
class generator;  
  randc bit [3:0] a,b; 
  bit [3:0] y;  
  int min;
  int max;
  
  function void pre_randomize();
    this.min = 3;
    this.max = 8;  
  endfunction
  
  constraint data {
    a inside {[min:max]};
    b inside {[min:max]};
  }
    
  function void post_randomize();
    $display("Value of a :%0d and b: %0d", a,b);
  endfunction
endclass

module tb8;  
  int i =0;
  generator g;  
  initial begin
    g = new();    
    for(i = 0; i<10;i++)begin
      g.randomize();
      #10;
    end    
  end
endmodule