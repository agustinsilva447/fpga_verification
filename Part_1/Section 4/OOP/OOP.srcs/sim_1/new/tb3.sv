`timescale 1ns / 1ps

module tb3();

    function bit[7:0] mul(input bit[7:0] x, y);
    return x*y;
    endfunction
    
    initial begin
        bit[7:0] a;
        bit[7:0] b;
        bit[7:0] c;
        
        a = 3;
        b = 2;
        c = mul(a,b);
        
        unique if (c == 6)
            $display("Test Passed");
        else
            $display("Test Failed");    
    end

    initial begin
        #200;
        $finish();
    end
    
endmodule