`timescale 1ns / 1ps

class transaction;
  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [7:0] mul;
  
  function void display();
    $display("a : %0d \t b: %0d \t mul : %0d",a,b,mul);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.a = this.a;
    copy.b = this.b;
    copy.mul = this.mul;
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

interface mul_if;
  logic [3:0] a;
  logic [3:0] b;
  logic [7:0] mul;
  logic clk;
endinterface
 
class driver;  
  virtual mul_if mif;
  mailbox #(transaction) mbx;
  transaction data;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    forever begin
      mbx.get(data);
      @(posedge mif.clk);  
      mif.a <= data.a;
      mif.b <= data.b;
      $display("[DRV] : Interface Trigger");
      data.display();
    end
  endtask
endclass

module tb6();
  mul_if mif();
  generator gen;
  driver drv;
  event done;
  
  mailbox #(transaction) mbx;
  top dut (.a(mif.a), .b(mif.b), .mul(mif.mul), .clk(mif.clk));
 
  initial begin
    mif.clk <= 0;
  end  
  always #10 mif.clk <= ~mif.clk;
 
  initial begin
    mbx = new();
    gen = new(mbx);
    drv = new(mbx);
    drv.mif = mif;
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