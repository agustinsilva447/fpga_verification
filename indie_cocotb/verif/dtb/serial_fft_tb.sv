module serial_fft_tb();
   localparam NBD      = 'd8;   
   localparam NBT      = 'd8;   
   localparam NSIZES   = 'd2;   
   localparam MAXSIZE  = 'd16;   
   
   reg                      clk;
   reg                      rst_async_n;
   reg [$clog2(NSIZES)-1:0] i_size;
   reg [NBD-1:0]            i_real;
   reg [NBD-1:0]            i_imag;
   reg                      i_valid;
   wire [NBD-1:0]           o_real;
   wire [NBD-1:0]           o_imag;
   wire                     o_valid;

   integer                  i;
   
   
   serial_fft
     #(.NBD    (NBD    ),
       .NBT    (NBT    ),
       .NSIZES (NSIZES ),
       .MAXSIZE(MAXSIZE))
   DUT 
   (.clk        (clk),
    .rst_async_n(rst_async_n),
    .i_size     (i_size),
    .i_real     (i_real),
    .i_imag     (i_imag),
    .i_valid    (i_valid),
    .o_real     (o_real),
    .o_imag     (o_imag),
    .o_valid    (o_valid));


   always#1
     clk = ~clk;
   
   initial
     begin
        clk         = 1'b0;
        rst_async_n = 1'b1;
        
        i_size      = 0;
        
        @(negedge clk);
        rst_async_n = 1'b0;
        @(negedge clk);
        rst_async_n = 1'b1;
        i_valid     = 1'b1;

        i_imag = 0;
        
        for(i=0;i<MAXSIZE>>i_size;i=i+1)
          begin
             i_real = i;
             @(posedge clk);             
          end
        i_real = 0;
     end
   
endmodule
