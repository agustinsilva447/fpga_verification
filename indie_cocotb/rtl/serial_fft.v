// *****************************************************************************
// Interface
// *****************************************************************************
module serial_fft#(
   // ----------------------------------
   // Parameters
   // ----------------------------------
   parameter                     NBD      = 'd8 , // Number of bits of data inputs and outputs.
   parameter                     NBT      = 'd8 , // Number of bits of the twiddles.
   parameter                     NSIZES   = 'd4 , // Number of different FFT sizes.
   parameter                     MAXSIZE  = 'd16  // FFT maximum size.
)(
  // ----------------------------------
  // Clock and reset inputs
  // ----------------------------------
   input                         clk            , // Posedge active clock.
   input                         rst_async_n    , // Low active asynchronous reset.
  // ----------------------------------
  // Inputs
  // ----------------------------------
   input  [$clog2(NSIZES)-1:0]   i_size         , // FFT size selector, i_size=0 is MAXSIZE.
   input  [NBD-1:0]              i_real         , // Input data sample, real part.
   input  [NBD-1:0]              i_imag         , // Input data sample, imaginary part.
   input                         i_valid        , // When high signalizes that there is a new valid input sample.
  // ----------------------------------
  // Outputs
  // ----------------------------------
   output [NBD-1:0]              o_real         , // Output data sample, real part.
   output [NBD-1:0]              o_imag         , // Output data sample, imaginary part.
   output reg                    o_valid          // When high signalizes that there is a new valid output sample.
);
// *****************************************************************************

// *****************************************************************************
// Architecture
// *****************************************************************************

   // -----------------------------------------------------
   // Local parameters
   // -----------------------------------------------------
   localparam NBC = $clog2(MAXSIZE);   // Number of bits of the main counter.
   
   // FSM's states definition
   localparam [1:0]  LOAD          = 2'b00,
                     PROCESS_READ  = 2'b01,
                     PROCESS_WRITE = 2'b10,
                     OUTPUT        = 2'b11;
   // -----------------------------------------------------

   // -----------------------------------------------------
   // Internal signals
   // -----------------------------------------------------
   reg                       load_ena;
   reg                       process_read_ena;
   reg                       process_write_ena;
   reg                       out_ena;
      
   reg [NBC-1:0]             counter_ff;
   reg [$clog2(NBC)-1:0]     stage_counter_ff;   
   
   wire [NBC-1:0]            counter_br;
   wire [NBC-1:0]            counter_br_at_size;
   wire [NBC-1:0]            circshift_at_size_x;
   wire [NBC-1:0]            circshift_at_size_y;   

   wire [NBD-1:0]            x_real_o;
   wire [NBD-1:0]            x_imag_o;
   wire [NBD-1:0]            x_real_i;
   wire [NBD-1:0]            x_imag_i;
   wire [NBD-1:0]            y_real_o;
   wire [NBD-1:0]            y_imag_o;
   wire [NBD-1:0]            y_real_i;
   wire [NBD-1:0]            y_imag_i;   

   wire [NBT-1:0]            twiddle_real;
   wire [NBT-1:0]            twiddle_imag;   
   wire [NBC-2:0]            twiddle_sel;   
   
   wire                      mem_en_A;
   wire                      mem_we_A;   
   wire                      mem_en_B;
   wire                      mem_we_B;   
   reg  [NBC-1:0]            mem_address_A;
   reg [NBC-1:0]             mem_address_B;
   reg [2*NBD-1:0]           mem_idata_A;
   reg [2*NBD-1:0]           mem_idata_B;
   reg [2*NBD-1:0]           mem_odata_A;
   reg [2*NBD-1:0]           mem_odata_B;
   
   reg [NBD*2-1:0]           data_mem [MAXSIZE-1:0];
   
   reg [1:0]                 state_ff;
   reg [1:0]                 state_nx;      

   genvar                    ii;
   
   wire [NBC-1:0]            selected_size;
   wire [$clog2(NBC)-1:0]    l2_selected_size;
   // -----------------------------------------------------
   
   assign selected_size = MAXSIZE-1 >> i_size;
   assign l2_selected_size = (NBC >> i_size) - 1;
   
   // MAIN COUNTER
   always@(posedge clk, negedge rst_async_n) begin : main_counter
      if(~rst_async_n) begin
         counter_ff <= {NBC{1'b0}};
      end
      else begin
         if((i_valid & load_ena) | (process_read_ena | process_write_ena) | out_ena) begin
            if(counter_ff == selected_size)
               counter_ff <= {NBC{1'b0}};
            else
               counter_ff <= counter_ff + 1'b1;
         end
      end
   end

   // BIT REVERSE    
   generate
      for(ii=0;ii<NBC;ii=ii+1) begin : counter_bitreverse
         assign counter_br[ii] = counter_ff[NBC-ii-1];
      end
   endgenerate

   assign counter_br_at_size = counter_br >> i_size;   
  
   // STAGE COUNTER
   always@(posedge clk) begin
      if(~rst_async_n) begin        
         stage_counter_ff <= {$clog2(NBC){1'b0}};        
      end
      else begin
         if((counter_ff == selected_size) && process_write_ena)               
            stage_counter_ff <= stage_counter_ff + 1'b1;
      end        
   end

   // CIRCSHIFT   
   wire [2*NBC-1:0] circshift_x_help;   
   assign circshift_x_help = {counter_ff&{{NBC-1{1'b1}},1'b0}, counter_ff&{{NBC-1{1'b1}},1'b0}};
   assign circshift_at_size_x = circshift_x_help >> NBC-stage_counter_ff;
   
   wire [2*NBC-1:0] circshift_y_help;
   assign circshift_y_help = {counter_ff&{{NBC-1{1'b1}},1'b0}|1'b1, counter_ff&{{NBC-1{1'b1}},1'b0}|1'b1};   
   assign circshift_at_size_y = circshift_y_help >> NBC-stage_counter_ff;

   // DATA MEMORY
   assign mem_idata_B = {y_real_o,y_imag_o};
   assign mem_en_A = (load_ena & i_valid) | process_write_ena | process_read_ena | out_ena;
   assign mem_en_B = process_write_ena | process_read_ena;   
   assign mem_we_A = load_ena | process_write_ena;   
   assign mem_we_B = process_write_ena;
   
   always@(posedge clk) begin : A_port          
      if (mem_en_A) begin
         if (mem_we_A)
            data_mem[mem_address_A] <= mem_idata_A;
         else
            mem_odata_A <= data_mem[mem_address_A];
      end
   end   

   always@(posedge clk) begin : B_port
      if (mem_en_B) begin
         if(mem_we_B)
            data_mem[mem_address_B] <= mem_idata_B;
         else
            mem_odata_B <= data_mem[mem_address_B];
      end
   end

   // MAIN STATE MACHINE - Next state assignment
   always@(*) begin : next_step_computation
      state_nx = LOAD;        
      case(state_ff)
         LOAD:
            begin
               if((counter_ff == selected_size) && (i_valid == 1'b1))
                 state_nx = PROCESS_READ;
               else
                 state_nx = LOAD;
            end
         PROCESS_READ:
            begin
               state_nx = PROCESS_WRITE;
            end
         PROCESS_WRITE:
            begin
               if((counter_ff == selected_size) && (stage_counter_ff == l2_selected_size))
                 state_nx = OUTPUT;
               else
                 state_nx = PROCESS_READ;
            end          
         OUTPUT:
                begin
                   if(counter_ff == selected_size)
                     state_nx = LOAD;
                   else
                     state_nx = OUTPUT;
                end
      endcase // case (state_ff)
   end // block: next_step_computation

   // MAIN STATE MACHINE - Output's assignment
   always@(*) begin : output_computation
      load_ena            = 1'b1;
      process_read_ena    = 1'b0;
      process_write_ena   = 1'b0; 
      out_ena             = 1'b0;
      
      mem_address_A = counter_br_at_size;
      mem_address_B = {NBC{1'b0}};
      mem_idata_A   = {i_real,i_imag};

      case(state_ff)
         LOAD:
            begin
               load_ena            = 1'b1;
               process_read_ena    = 1'b0;
               process_write_ena   = 1'b0;
               out_ena             = 1'b0;
               mem_address_A       = counter_br_at_size;
               mem_address_B       = {NBC{1'b0}};        
               mem_idata_A         = {i_real,i_imag};        
            end
         PROCESS_READ:
            begin
               load_ena            = 1'b0;
               process_read_ena    = 1'b1;
               process_write_ena   = 1'b0;
               out_ena             = 1'b0;
               mem_address_A       = circshift_at_size_x; 
               mem_address_B       = circshift_at_size_y; 
               mem_idata_A         = {x_real_o,x_imag_o};
            end
         PROCESS_WRITE:
            begin
               load_ena            = 1'b0;
               process_read_ena    = 1'b0;
               process_write_ena   = 1'b1;
               out_ena             = 1'b0;
               mem_address_A       = circshift_at_size_x;
               mem_address_B       = circshift_at_size_y;
               mem_idata_A         = {x_real_o,x_imag_o};
            end
         OUTPUT:
            begin
               load_ena            = 1'b0;
               process_read_ena    = 1'b0;
               process_write_ena   = 1'b0;
               out_ena             = 1'b1;
               mem_address_A       = counter_ff;
               mem_address_B       = {NBC{1'b0}};
               mem_idata_A         = {i_real,i_imag};
            end
      endcase // case (state_ff)
   end

   // Current state register
   always@(posedge clk, negedge rst_async_n) begin : state_register
      if(~rst_async_n) begin
         state_ff <= LOAD;             
      end
      else begin
         state_ff <= state_nx;             
      end
   end

   // TWIDDLE SEL BITMASK
   wire [NBC-2:0] mask;

   assign mask = {NBC-1{1'b1}} << NBC-1 - stage_counter_ff;
   assign twiddle_sel = (counter_ff>>1) & mask;
   
   // TWIDLE ROM
   twiddle_rom u_twiddle_rom (
      .i_sel            (twiddle_sel   ),
      .o_twiddle_real   (twiddle_real  ),
      .o_twiddle_imag   (twiddle_imag  )
   );
  
   // BUTTERFLY
   assign x_real_i = mem_odata_A[2*NBD-1-:NBD];
   assign x_imag_i = mem_odata_A[NBD-1-:NBD];

   assign y_real_i = mem_odata_B[2*NBD-1-:NBD];
   assign y_imag_i = mem_odata_B[NBD-1-:NBD];
   
   butterfly #(
      .NBD              (NBD           ),
      .NBT              (NBT           )
   ) u_butterfly (
      .i_x_real         (x_real_i      ),
      .i_x_imag         (x_imag_i      ),
      .i_y_real         (y_real_i      ),
      .i_y_imag         (y_imag_i      ),
      .i_twiddle_real   (twiddle_real  ),
      .i_twiddle_imag   (twiddle_imag  ),
      .o_x_real         (x_real_o      ),
      .o_x_imag         (x_imag_o      ),
      .o_y_real         (y_real_o      ),
      .o_y_imag         (y_imag_o      )
   );

   assign o_real = mem_odata_A[2*NBD-1-:NBD];
   assign o_imag = mem_odata_A[NBD-1-:NBD];

   always@(posedge clk, negedge rst_async_n) begin
      if(~rst_async_n) begin
         o_valid <= 1'b0;
      end
      else begin
         o_valid <= out_ena;
      end
   end

// *****************************************************************************
endmodule
