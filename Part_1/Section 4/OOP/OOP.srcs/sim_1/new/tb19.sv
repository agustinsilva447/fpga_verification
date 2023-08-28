`timescale 1ns / 1ps

class first;
  int data = 12;  
  
  function first copy();
    copy = new();
    copy.data = data;
  endfunction
endclass
 
class second;  
  int ds = 34;  
  first f1;
    
  function new();
    f1 = new();
  endfunction
  
  function second copy();
    copy = new();
    copy.ds = ds;
    copy.f1 = f1.copy;    
  endfunction
endclass
 
module tb19;  
  second s1, s2;
  
  initial begin
    s1 = new();
    s2 = new();    
    s1.ds = 45;    
    s2 = s1.copy();    
    $display("Value of s2 : %0d", s2.ds);    
    s2.ds = 78;    
    $display("Value of s1 : %0d", s1.ds);    
    s2.f1.data = 98;    
    $display("Value of s1 : %0d", s1.f1.data);             
  end      
endmodule