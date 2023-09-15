// *****************************************************************************
// Interface
// *****************************************************************************
module twiddle_rom (
  // ----------------------------------
  // Inputs
  // ----------------------------------
   input         [3-1:0]   i_sel          , // Twiddle selector.
  // ----------------------------------
  // Outpus
  // ----------------------------------
   output signed [8-1:0]   o_twiddle_real , // Twiddle value, real part.
   output signed [8-1:0]   o_twiddle_imag   // Twiddle value, imaginary part.
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
   wire signed [8-1:0] twiddle_real_rom [16/2-1:0];
   wire signed [8-1:0] twiddle_imag_rom [16/2-1:0];
   // -----------------------------------------------------
 
   assign o_twiddle_real = twiddle_real_rom[i_sel];
   assign o_twiddle_imag = twiddle_imag_rom[i_sel];

   assign twiddle_real_rom[0] = 127;
   assign twiddle_imag_rom[0] = 0;
   assign twiddle_real_rom[1] = 118;
   assign twiddle_imag_rom[1] = -49;
   assign twiddle_real_rom[2] = 91;
   assign twiddle_imag_rom[2] = -91;
   assign twiddle_real_rom[3] = 49;
   assign twiddle_imag_rom[3] = -118;
   assign twiddle_real_rom[4] = 0;
   assign twiddle_imag_rom[4] = -128;
   assign twiddle_real_rom[5] = -49;
   assign twiddle_imag_rom[5] = -118;
   assign twiddle_real_rom[6] = -91;
   assign twiddle_imag_rom[6] = -91;
   assign twiddle_real_rom[7] = -118;
   assign twiddle_imag_rom[7] = -49;

// *****************************************************************************
endmodule
