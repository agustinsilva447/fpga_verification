`timescale 1ns / 1ps

module tb5;  

  int i1 = 0, i2 = 0;
  
  task first();
    forever begin
      #20;      
      $display("Task 1 Trigger at %0t",$time);
      i1 = i1 + 1;
    end
  endtask    
    
  task second();
    forever begin
      #40;      
      $display("Task 2 Trigger at %0t",$time);
      i2 = i2 + 1;
    end
  endtask  
    
  initial begin
    fork
      first();
      second();
    join
  end
  
  initial begin
    #200;
    $display("Event 1 ocurred %0d and Event 2 ocurred %0d", i1, i2);
    $finish();  
  end
endmodule