`timescale 1ns / 1ps

module tb8();

    reg sclk = 0;
  
    always #55.555 sclk = ~sclk;

    initial begin
        #500;
        $finish();
    end

endmodule