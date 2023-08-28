`timescale 1ns / 1ps

class uclass;  
  bit [7:0] data1;
  bit [7:0] data2;
  bit [7:0] data3;    
endclass 

module tb2();
    uclass uc;
    initial begin
    uc = new();
    uc.data1 = 45;
    uc.data2 = 78;
    uc.data3 = 90;
    #1;
    $display("Values of data : %0d, %0d and %0d",uc.data1, uc.data2, uc.data3);   
    end

    initial begin
        #200;
        $finish();
    end
endmodule