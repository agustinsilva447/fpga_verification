`timescale 1ns / 1ps

class transaction;
  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [4:0] sum;
  
  function void display();
    $display("a : %0d \t b: %0d \t sum : %0d",a,b,sum);
  endfunction
  
  virtual function transaction copy();
    copy = new();
    copy.a = this.a;
    copy.b = this.b;
    copy.sum = this.sum;
  endfunction  
endclass
 
class error extends transaction;
  //constraint data_c {a == 0 ;  b == 0;} // ERROR FROM GENERATOR
  
  function transaction copy();            // ERROR FROM DRIVER
    copy = new();
    copy.a = 0; 
    copy.b = 0;
    copy.sum = this.sum;
  endfunction  
endclass
  
class generator;
  transaction trans;
  mailbox #(transaction) mbx;
  event done;
 
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    trans = new();
  endfunction
  
  task run();
    for(int i = 0; i<10; i++) begin
      trans.randomize();
      mbx.put(trans.copy);
      $display("[GEN] : DATA SENT TO DRIVER");
      trans.display();
      #20;
    end
    -> done;
  endtask
endclass
 
interface add_if;
  logic [3:0] a;
  logic [3:0] b;
  logic [4:0] sum;
  logic clk;
endinterface
 
class driver;
  virtual add_if aif;
  mailbox #(transaction) mbx;
  transaction data;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction 
  
  task run();
    forever begin
      mbx.get(data);
      @(posedge aif.clk);  
      aif.a <= data.a;
      aif.b <= data.b;
      $display("[DRV] : Interface Trigger");
      data.display();
    end
  endtask
endclass
 
module tb7;
  add_if aif();
  driver drv;
  generator gen;
  event next;  
  event done;
  error er;
  mailbox #(transaction) mbx;
  add dut (aif.a, aif.b, aif.sum, aif.clk );
 
  initial begin
    aif.clk <= 0;
  end  
  always #10 aif.clk <= ~aif.clk;
 
  initial begin
    mbx = new();
    drv = new(mbx);
    gen = new(mbx);
    drv.aif = aif;
    er = new();
    gen.trans = er;
    done = gen.done;     
  end
  
  initial begin
    fork
      gen.run();
      drv.run();
    join_none
      wait(done.triggered);
      $finish();
  end
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;  
  end  
endmodule