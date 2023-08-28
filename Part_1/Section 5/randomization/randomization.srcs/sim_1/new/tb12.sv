`timescale 1ns / 1ps

class generator;  
  randc bit [3:0] a;
  rand bit ce;
  rand bit rst;
  
  constraint control_rst {
    rst dist {0:= 80, 1:= 20};
  }    
  
  constraint control_ce {
    ce dist {0:= 20, 1:= 80};
  }
  
  constraint control_rst_ce {
    rst == 0 -> ce == 1; 
  }  
  
endclass
 
module tb12;  
  generator g;  
  initial begin
    g = new();    
    for (int i = 0; i<20 ; i++) begin
      assert (g.randomize()) else $display("Randomization Failed");
      $display("Value of rst : %0b and ce : %0b", g.rst, g.ce);
      #10;
    end    
  end
endmodule