`timescale 1ns / 1ps

class generator;  
  randc bit [7:0] x,y,z; ////////////rand or randc
  
  constraint data {
    x inside {[0:50]};
    y inside {[0:50]};
    z inside {[0:50]};
  }
endclass

module tb7();
  generator g;
  int i = 0;
  
  initial begin    
    for (i=0;i<20;i++) begin
      g = new();
      assert (g.randomize()) else 
        begin
          $display("Randomization Failed at %0t", $time); 
          $finish();
        end      
      $display("%0d th set of values [x, y, z] = [%0d, %0d, %0d]",i+1,g.x,g.y, g.z);
      #20;
    end    
  end  
endmodule