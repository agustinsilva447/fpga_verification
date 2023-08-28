`timescale 1ns / 1ps

module tb6();

    byte arr1[20];
    byte arr2[$];
    
    initial begin
        for(int i = 0 ; i < $size(arr1) ; i++) begin
            arr1[i] = $urandom();
            arr2.push_front(arr1[i]);
        end
        $display("Value of arr1 : %0p", arr1);
        $display("Value of arr2 : %0p", arr2);    
    end;

    initial begin
        #200;
        $finish();
    end

endmodule