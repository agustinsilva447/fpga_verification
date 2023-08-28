`timescale 1ns / 1ps

class transaction; 
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit wr; 
endclass
 
class generator;  
  transaction t;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;  
  endfunction
  
  task main();    
    for(int i = 0; i < 10; i++) begin
      t = new();
      assert(t.randomize) else $display("Randomization Failed");
      $display("[GEN] : DATA SENT : a : %0d and b : %0d", t.a, t.b);
      mbx.put(t);      
      #10;
    end
  endtask  
endclass 
 
class driver;  
  transaction t;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;  
  endfunction
  
  task main();
    forever begin
      mbx.get(t);
      $display("[DRV] : DATA RCVD : a : %0d and b : %0d", t.a, t.b);
      #10;
    end
  endtask  
endclass

module tb12();
  generator g;
  driver d;
  mailbox #(transaction) mbx;
  
  initial begin
    mbx = new();
    g = new(mbx);
    d = new(mbx);
    
    fork 
      g.main();
      d.main();
    join      
  end
  
  initial begin
    #250;
    $finish();
  end    
endmodule