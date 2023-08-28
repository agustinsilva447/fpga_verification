`timescale 1ns / 1ps

class first;  ///parent class
  int data = 12;  
  virtual function void display();
     $display("FIRST : Value of data : %0d", data);
  endfunction
endclass
 
 
class second extends first; //child class  
  int temp = 34;  
  function void add();
    $display("secomd:Value after process : %0d", temp+4);
  endfunction  
 
  function void display();
    $display("SECOND : Value of data : %0d", data);
  endfunction
endclass
  
module tb21;
  
  first f;
  second s;  
  
  initial begin
    f = new();
    s = new();  
    f.display();  
    f = s;
    f.display();    
  end
endmodule
