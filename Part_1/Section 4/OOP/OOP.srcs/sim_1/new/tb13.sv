`timescale 1ns / 1ps

class fourth;  
    bit [3:0] a;
    bit [3:0] b;
    bit [3:0] c;
    bit [5:0] d;
    
  
    function new(input bit[7:0] a = 4'h0, input bit[7:0] b = 4'h0, input bit[7:0] c = 4'h0);
        this.a = a;
        this.b = b;
        this.c = c;    
    endfunction    
    
    task addition();
        d = a + b + c;
        $display("a + b + c = %0d + %0d + %0d = %0d", a, b, c, d);
    endtask
endclass 

module tb13();
    bit [3:0] data1 = 1;
    bit [3:0] data2 = 2;
    bit [3:0] data3 = 4;
    
    fourth f1;
    initial begin
        f1 = new(.a(data1),.b(data2),.c(data3)); //follow name
        f1.addition();
    end    
endmodule