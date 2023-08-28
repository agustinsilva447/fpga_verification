`timescale 1ns / 1ps

class generator;  
  bit [3:0] a = 5, b =7;
  bit wr = 1;
  bit en = 1;
  bit [4:0] s = 12;
  
  function void display();
    $display("a:%0d b:%0d wr:%0b en:%0b s:%0d", a,b,wr,en,s);
  endfunction 
  
  function generator copy();
    copy = new();
    copy.a = a;
    copy.b = b;
    copy.wr = wr;
    copy.en = en;
    copy.s = s;
  endfunction
endclass

module tb20();
    generator g1, g2;
    
    initial begin
        g1 = new();
        g2 = new();
        g2 = g1.copy();
        g1.display;
        g2.display;
        g1.a = 6;
        g2.a = 7;      
        g1.display;
        g2.display;  
    end
endmodule