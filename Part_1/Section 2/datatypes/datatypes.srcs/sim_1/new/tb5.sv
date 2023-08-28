`timescale 1ns / 1ps

module tb5();

    int arr[];
    
    initial begin
    
        arr = new[7];        
        for(int i = 0 ; i < $size(arr) ; i++) begin
            arr[i] = 7 * (i+1);
        end;        
        $display("Value of arr : %0p", arr);
        #20;
        arr = new[20](arr);
        for(int i = 7 ; i < $size(arr) ; i++) begin
            arr[i] = 5 * (i-6);
        end;   
        $display("Value of arr : %0p", arr);
    end;

    initial begin
        #200;
        $finish();
    end

endmodule
