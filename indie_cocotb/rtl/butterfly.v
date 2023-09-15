// *****************************************************************************
// Interface
// *****************************************************************************
module butterfly #(
   // ----------------------------------
   // Parameters
   // ----------------------------------
   parameter                  NBD = 'd8      , // Number of bits of data inputs and outputs.
   parameter                  NBT = 'd8        // Number of bits of the twiddles.
)(
  // ----------------------------------
  // Inputs
  // ----------------------------------
   input  signed [NBD-1:0]    i_x_real       , // Data input 1, real part.
   input  signed [NBD-1:0]    i_x_imag       , // Data input 1, imaginary part.
   input  signed [NBD-1:0]    i_y_real       , // Data input 2, real part.
   input  signed [NBD-1:0]    i_y_imag       , // Data input 2, imaginary part.
   input  signed [NBT-1:0]    i_twiddle_real , // Twiddle input, real part.
   input  signed [NBT-1:0]    i_twiddle_imag , // Twiddle input, imaginary part.
  // ----------------------------------
  // Outputs
  // ----------------------------------
   output signed [NBD-1:0]    o_x_real       , // Data output 1, real part.
   output signed [NBD-1:0]    o_x_imag       , // Data output 1, imaginary part.
   output signed [NBD-1:0]    o_y_real       , // Data output 2, real part.
   output signed [NBD-1:0]    o_y_imag         // Data output 2, imaginary part.
);
// *****************************************************************************

// *****************************************************************************
// Architecture
// *****************************************************************************

   // -----------------------------------------------------
   // Local parameters
   // -----------------------------------------------------
   // None.
   // -----------------------------------------------------

   // -----------------------------------------------------
   // Internal signals
   // -----------------------------------------------------
   wire signed [NBD+NBT-1:0] pp_y_rr;
   wire signed [NBD+NBT-1:0] pp_y_ri;
   wire signed [NBD+NBT-1:0] pp_y_ir;
   wire signed [NBD+NBT-1:0] pp_y_ii;

   wire signed [NBD:0]     mult_y_real;
   wire signed [NBD:0]     mult_y_imag;

   wire signed [NBD:0] pre_x_real;
   wire signed [NBD:0] pre_x_imag;
   wire signed [NBD:0] pre_y_real;
   wire signed [NBD:0] pre_y_imag;
   // -----------------------------------------------------

   // Multiplicate data input 2 by twiddle factor (complex multiplication).
   assign pp_y_rr = i_y_real * i_twiddle_real;
   assign pp_y_ii = i_y_imag * i_twiddle_imag;
   assign pp_y_ir = i_y_imag * i_twiddle_real;
   assign pp_y_ri = i_y_real * i_twiddle_imag;

   // Shift result in order to be aligned to input data
   assign mult_y_real = (pp_y_rr - pp_y_ii) >>> (NBT-1);
   assign mult_y_imag = (pp_y_ri + pp_y_ir) >>> (NBT-1);

   // Butterfly add and subtract operations 
   assign pre_x_real = i_x_real + mult_y_real;
   assign pre_x_imag = i_x_imag + mult_y_imag;
   assign pre_y_real = i_x_real - mult_y_real;
   assign pre_y_imag = i_x_imag - mult_y_imag;
   
   // Shift result
   assign o_x_real = pre_x_real >>> 1;
   assign o_x_imag = pre_x_imag >>> 1;
   assign o_y_real = pre_y_real >>> 1;
   assign o_y_imag = pre_y_imag >>> 1;

// *****************************************************************************
endmodule