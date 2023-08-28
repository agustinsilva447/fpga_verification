`timescale 1ns / 1ps

class first;  
  int data;  
endclass
 
module tb16;
  
  first f1;
  first p1;  
  
  initial begin
    f1      = new();    ///1. constructor 
    f1.data = 24;       ///2. processing
    p1      = new f1;   /// 3. copying data from f1 to p1
    $display("Value of data member : %0d", p1.data);    //4. processing 
    p1.data = 12;
    $display("Value of data member : %0d", f1.data); 
  end

endmodule