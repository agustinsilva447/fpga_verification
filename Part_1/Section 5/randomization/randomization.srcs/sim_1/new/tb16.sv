`timescale 1ns / 1ps

class generator;  
  rand bit [3:0] addr;
  rand bit wr;
 
  constraint write_read {    
    if(wr == 1)
    {
      addr inside {[0:7]};
    }
    else
    {
      addr inside {[8:15]};  
    }           
  }   
endclass
 
module tb16();
  generator g;  
  initial begin
    g = new();    
    for (int i = 0; i<20 ; i++) begin
      assert (g.randomize()) else $display("Randomization Failed.");
      $display("Value of wr : %0b and  addr : %0d.", g.wr, g.addr);
      #10;
    end    
  end   
endmodule