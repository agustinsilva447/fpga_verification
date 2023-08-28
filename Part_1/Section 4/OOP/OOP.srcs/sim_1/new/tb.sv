`timescale 1ns / 1ps

class first;  
  reg [2:0] data; 
  reg [1:0] data2;    
endclass 
 
module tb; 
  first f;  
  initial begin
    f = new(); 
    f.data  = 3'b010;
    f.data2 = 2'b10;
    #1;
    $display("Value of data : %0d and data2 : %0d",f.data, f.data2);    
    f = null; 
  end
endmodule