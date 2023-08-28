`timescale 1ns / 1ps

module tb6; 
    //////pass by value
    task swap1 (input bit [1:0] a, input bit [1:0] b); 
        bit [1:0] temp;
        temp = a;
        a = b;
        b = temp;   
        $display("Value of a : %0d and b : %0d", a,b);
    endtask
  
    //////pass by reference  
    task automatic swap2 (ref bit [1:0] a, ref bit [1:0] b); /// function automatic bit [1:0] add (arguments);
        bit [1:0] temp;
        temp = a;
        a = b;
        b = temp;        
        $display("Value of a : %0d and b : %0d", a,b);
    endtask 
  
    ////restrict access to variables
    task automatic swap3 (const ref bit [1:0] a, ref bit [1:0] b); /// function automatic bit [1:0] add (arguments);
        bit [1:0] temp;    
        temp = a;
        //  a = b;
        b = temp;    
        $display("Value of a : %0d and b : %0d", a,b);
    endtask
  
  bit [1:0] a;
  bit [1:0] b;
  
  initial begin
    a = 1;
    b = 2;    
    swap2(a,b);    
    $display("Value of a : %0d and b : %0d", a,b);
  end
  
endmodule
