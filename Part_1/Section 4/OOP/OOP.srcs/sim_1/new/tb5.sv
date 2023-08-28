`timescale 1ns / 1ps

module tb5();
    bit en  = 0;
    bit wr  = 0;  
    bit clk = 0;   
    bit [6:0] addr; 
    
    always #20 clk = ~clk;  ///40 ns --> 25 Mhz
    
    task addr_gen();
        @(posedge clk);
        addr = $urandom();
    endtask
  
    task genera();
        @(posedge clk);    // wait
        en = 1;
        wr = 1;
        #80
        wr = 0;
        #80
        en = 0;
    endtask
    
    initial begin
        genera();
    end
    
    initial begin
        for(int i = 0; i< 10 ; i++) begin
            addr_gen();
        end          
    end
  
    initial begin
        #200;
        $finish();
    end

endmodule