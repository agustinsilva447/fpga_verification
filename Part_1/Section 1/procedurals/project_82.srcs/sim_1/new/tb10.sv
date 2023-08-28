`timescale 1ns / 1ps

module tb10();
  
    reg clk1 = 0; 
    reg clk2 = 0;
  
    always #5 clk1 = ~clk1; //100 MHz

    task calc (input real period, input real duty_cycle, output real ton, output real toff);
        ton = period * duty_cycle;
        toff =  period - ton;
    endtask 
 
    task clkgen(input real ton, input real toff);  
        @(posedge clk1);
        while(1) begin
            clk2 = 1;
            #ton;
            clk2 = 0;
            #toff;
        end
    endtask
     
    real ton;
    real toff; 
 
    initial begin
        calc(40, 0.4, ton, toff);
        clkgen(ton, toff);
    end
    
    initial begin
        #200;
        $finish();
    end
    
endmodule
