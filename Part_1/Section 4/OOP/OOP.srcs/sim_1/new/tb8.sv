`timescale 1ns / 1ps

module tb8();
  
    bit [7:0] res[32];
  
    function automatic void init_arr (ref bit [7:0] a[32]);  
        for(int i =0; i < $size(a); i++) begin
            a[i] = 8*i;
        end
    endfunction 
  
    initial begin
        init_arr(res);    
        for(int i =0; i < $size(res); i++) begin
            $display("res[%0d] : %0d", i, res[i]);
        end
    end
    
endmodule