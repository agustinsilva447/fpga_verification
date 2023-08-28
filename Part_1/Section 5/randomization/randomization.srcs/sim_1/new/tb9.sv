`timescale 1ns / 1ps

class generator;
  rand bit [4:0] a;
  rand bit [5:0] b;   
  constraint data_a {0 <= a; a <= 8;}   
  constraint data_b {0 <= b; b <= 5;}   
endclass

module tb9();
  generator g;
  int i = 0;  
  int j = 0;  
  initial begin    
    for (i=0;i<20;i++) begin
      g = new();
      g.randomize();
      assert ((0 <= g.a <= 8) && (0 <= g.b < 5)) else
      begin
        $display("Randomization Failed at %0t.", $time);
        j = j+1;
      end
      $display("Value of a :%0d and b: %0d.", g.a,g.b);
      #10;
    end    
    $display("Total number of errors: %0d.", j);
  end  
endmodule