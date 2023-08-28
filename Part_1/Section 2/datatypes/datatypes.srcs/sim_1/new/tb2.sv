`timescale 1ns / 1ps

module tb2();

    bit[7:0] arr[10];
    
    initial begin
        for(bit[7:0] i = 0 ; i < $size(arr) ; i++) begin
            arr[i] = i * i;
        end
        
        $display("Value of arr : %0p", arr);
    end;

endmodule