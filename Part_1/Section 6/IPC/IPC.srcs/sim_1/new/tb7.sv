`timescale 1ns / 1ps

class generator;
  int data = 12;
  mailbox mbx;  
  
  task run();
    mbx.put(data);
    $display("[GEN] : Data Sent : %0d ",data);
  endtask
endclass
 
class driver;
  mailbox mbx;
  int data;
  
  task run();
    mbx.get(data);
    $display("[DRV] : DATA rcvd : %0d",data);
  endtask    
endclass
 
module tb7;
  generator gen;
  driver drv;
  mailbox mbx;
  
  initial begin
    gen = new();
    drv = new();
    mbx = new();
    
    gen.mbx = mbx;
    drv.mbx = mbx; 
    
    gen.run();
    drv.run();
  end
  
  initial begin
    #250;
    $finish();
  end  
endmodule