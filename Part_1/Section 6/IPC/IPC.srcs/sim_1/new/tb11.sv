`timescale 1ns / 1ps

class transaction;
    bit [7:0] addr = 7'h12;
    bit [3:0] data = 4'h4;
    bit         we = 1'b1;
    bit        rst = 1'b0;
endclass
 
class generator;  
  transaction t;  
  mailbox #(transaction)  mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction  
  
  task run();
    t = new();
    mbx.put(t);
    $display("[GEN] : Data 1 Send from Gen : %0d ",t.addr);
    $display("[GEN] : Data 2 Send from Gen : %0d ",t.data);
    $display("[GEN] : Data 3 Send from Gen : %0d ",t.we);
    $display("[GEN] : Data 4 Send from Gen : %0d ",t.rst);
  endtask  
endclass
 
class driver;
  transaction t;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction)  mbx);
    this.mbx = mbx;
  endfunction    
  
  task run();
    mbx.get(t);
    $display("[DRV] : Data 1 rcvd from Gen : %0d",t.addr);
    $display("[DRV] : Data 2 rcvd from Gen : %0d",t.data);
    $display("[DRV] : Data 3 rcvd from Gen : %0d",t.we);
    $display("[DRV] : Data 4 rcvd from Gen : %0d",t.rst);
  endtask    
endclass 

module tb11();
  generator gen;
  driver    drv;
  mailbox   #(transaction) mbx;
  
  initial begin 
    mbx = new();
    gen = new(mbx);
    drv = new(mbx); 
    
    gen.run();
    drv.run();
  end
  
  initial begin
    #250;
    $finish();
  end    
endmodule