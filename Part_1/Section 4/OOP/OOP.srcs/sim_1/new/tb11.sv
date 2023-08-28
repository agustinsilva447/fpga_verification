`timescale 1ns / 1ps

class second;  
    bit [7:0] a;
    bit [7:0] b;
    bit [7:0] c;
  
    function new(input bit[7:0] a = 8'h00, input bit[7:0] b = 8'h00, input bit[7:0] c = 8'h00);
        this.a = a;
        this.b = b;
        this.c = c;    
    endfunction    
endclass 

module tb11();
    bit [7:0] data1 = 2;
    bit [7:0] data2 = 4;
    bit [7:0] data3 = 56;
    second s1;
    initial begin
        s1 = new(.a(data1),.b(data2),.c(data3)); //follow name
        $display("Data1 : %0d, Data2 : %0d and Data3 : %0d", s1.a, s1.b, s1.c); 
    end    
endmodule