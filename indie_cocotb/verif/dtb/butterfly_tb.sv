`define NULL 0
module butterfly_tb();
   
   localparam NBD = 'd8;
   localparam NBT = 'd8;
   
   reg [NBD-1:0]  i_x_real;
   reg [NBD-1:0]  i_x_imag;
   reg [NBD-1:0]  i_y_real;
   reg [NBD-1:0]  i_y_imag;
   reg [NBT-1:0]  i_twiddle_real;
   reg [NBT-1:0]  i_twiddle_imag;
   wire [NBD-1:0] o_x_real;
   wire [NBD-1:0] o_x_imag;
   wire [NBD-1:0] o_y_real;
   wire [NBD-1:0] o_y_imag;         

   reg [NBD-1:0]  o_x_real_tb;
   reg [NBD-1:0]  o_x_imag_tb;
   reg [NBD-1:0]  o_y_real_tb;
   reg [NBD-1:0]  o_y_imag_tb;         
   

   butterfly
     #(.NBD(NBD),
       .NBT(NBT))
   DUT
     (.i_x_real          (i_x_real),          
      .i_x_imag          (i_x_imag),          
      .i_y_real          (i_y_real),          
      .i_y_imag          (i_y_imag),          
      .i_twiddle_real    (i_twiddle_real),    
      .i_twiddle_imag    (i_twiddle_imag),    
      .o_x_real          (o_x_real),          
      .o_x_imag          (o_x_imag),          
      .o_y_real          (o_y_real),          
      .o_y_imag          (o_y_imag));         
      

   reg                   clk;
   integer               r;
   integer               i_x_real_file;
   integer               i_x_imag_file;
   integer               i_y_real_file;
   integer               i_y_imag_file;
   integer               i_twiddle_real_file;
   integer               i_twiddle_imag_file;
   integer               o_x_real_file;
   integer               o_x_imag_file;
   integer               o_y_real_file;
   integer               o_y_imag_file;
   
   reg [8*120-1:0]       path;
   
   always#1
     clk = ~clk;   
   
   initial
     begin
`ifdef VIVADO
        path = "../../../vectors/";        
`else
        path  = "./vectors/";
`endif
        
        clk = 1'b0;

	     i_x_real_file = $fopen({path,"i_x_real.dat"},"r");
	     if (i_x_real_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end
        
	     i_x_imag_file = $fopen({path,"i_x_imag.dat"},"r");
	     if (i_x_imag_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end

	     i_y_real_file = $fopen({path,"i_y_real.dat"},"r");
	     if (i_y_real_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end
        
	     i_y_imag_file = $fopen({path,"i_y_imag.dat"},"r");
	     if (i_y_imag_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end
 
	     i_twiddle_real_file = $fopen({path,"i_twiddle_real.dat"},"r");
	     if (i_twiddle_real_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end
        
	     i_twiddle_imag_file = $fopen({path,"i_twiddle_imag.dat"},"r");
	     if (i_twiddle_imag_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end       

	     o_x_real_file = $fopen({path,"o_x_real.dat"},"r");
	     if (o_x_real_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end
        
	     o_x_imag_file = $fopen({path,"o_x_imag.dat"},"r");
	     if (o_x_imag_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end

	     o_y_real_file = $fopen({path,"o_y_real.dat"},"r");
	     if (o_y_real_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end
        
	     o_y_imag_file = $fopen({path,"o_y_imag.dat"},"r");
	     if (o_y_imag_file == `NULL)
	       begin
             $display("Unable to open file");
             $stop;
	       end        
     end // initial begin


   always@(posedge clk)
     begin

	     r = $fscanf(i_x_real_file, "%d", i_x_real); 
        if($feof(i_x_real_file))
          $finish;
	     r = $fscanf(i_x_imag_file, "%d", i_x_imag); 
        if($feof(i_x_imag_file))
          $finish;
	     r = $fscanf(i_y_real_file, "%d", i_y_real); 
        if($feof(i_y_real_file))
          $finish;
	     r = $fscanf(i_y_imag_file, "%d", i_y_imag); 
        if($feof(i_y_imag_file))
          $finish;
	     r = $fscanf(i_twiddle_real_file, "%d", i_twiddle_real); 
        if($feof(i_twiddle_real_file))
          $finish;
	     r = $fscanf(i_twiddle_imag_file, "%d", i_twiddle_imag); 
        if($feof(i_twiddle_imag_file))
          $finish;
        r = $fscanf(o_x_real_file, "%d", o_x_real_tb); 
        if($feof(o_x_real_file))
          $finish;
	     r = $fscanf(o_x_imag_file, "%d", o_x_imag_tb); 
        if($feof(o_x_imag_file))
          $finish;
	     r = $fscanf(o_y_real_file, "%d", o_y_real_tb); 
        if($feof(o_y_real_file))
          $finish;
	     r = $fscanf(o_y_imag_file, "%d", o_y_imag_tb); 
        if($feof(o_y_imag_file))
          $finish;
        
     end

always@(posedge clk)
  begin
     #1
   assert(o_x_real==o_x_real_tb);
   assert(o_x_imag==o_x_imag_tb);
   assert(o_y_real==o_y_real_tb);
   assert(o_y_imag==o_y_imag_tb);
   
end   
       
   
endmodule
