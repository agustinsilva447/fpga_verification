`timescale 1ns / 1ps

module tb1();

    reg [7:0] a;
    reg [7:0] b;
    integer c;
    integer d;
    
    
    initial begin
        a = 8'd12;
        b = 8'd34;
        c = 32'd67;
        d = 32'd255;        
    end
    
    initial begin
        #12
        $monitor("Value of a: %0d at time : %0t", a, $time);
        $monitor("Value of b: %0d at time : %0t", b, $time);
        $monitor("Value of c: %0d at time : %0t", c, $time);
        $monitor("Value of d: %0d at time : %0t", d, $time);
    end

    initial begin
        #200;
        $finish();
    end
    
endmodule
