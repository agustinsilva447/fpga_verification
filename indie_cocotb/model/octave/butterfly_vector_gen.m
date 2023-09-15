
function butterfly_vector_gen()

  NBD = 8;
  NBT = 8;

  L = 1000;
  rng(7);
  i_x  = randi(256,1,L)-1-2^(NBD-1) + 1i *(randi(2^NBD,1,L)-1-2^(NBD-1));
  i_y  = randi(256,1,L)-1-2^(NBD-1) + 1i *(randi(2^NBD,1,L)-1-2^(NBD-1));
  
  i_twiddle = floor(exp(1i*2*pi*(randi(512)-1)/512)*2^(NBT-1) +(0.5+1i*0.5));
  i_twiddle = complex(real(i_twiddle>=2^(NBT-1))*(2^(NBT-1)-1)+real(i_twiddle<2^(NBT-1))*real(i_twiddle),imag(i_twiddle>=2^(NBT-1))*(2^(NBT-1)-1)+imag(i_twiddle<2^(NBT-1))*imag(i_twiddle));
  o_x = zeros(1,L);
  o_y = zeros(1,L);
  
  
  PATH        = '../../verif/rundir/vectors/';
  fid_i_x_real  = fopen([PATH 'i_x_real.dat'],'w+');
  fid_i_x_imag  = fopen([PATH 'i_x_imag.dat'],'w+');
  fid_i_y_real  = fopen([PATH 'i_y_real.dat'],'w+');
  fid_i_y_imag  = fopen([PATH 'i_y_imag.dat'],'w+');                     
  fid_i_twiddle_real = fopen([PATH 'i_twiddle_real.dat'],'w+');
  fid_i_twiddle_imag = fopen([PATH 'i_twiddle_imag.dat'],'w+');
  fid_o_x_real = fopen([PATH 'o_x_real.dat'],'w+');
  fid_o_x_imag = fopen([PATH 'o_x_imag.dat'],'w+');
  fid_o_y_real = fopen([PATH 'o_y_real.dat'],'w+');
  fid_o_y_imag = fopen([PATH 'o_y_imag.dat'],'w+');  
                 
  for i=1:1000

    [o_x(i),o_y(i)] = my_butterfly(i_x(i),i_y(i),i_twiddle(i),NBT);

    fprintf(fid_i_x_real, '%d\n',real(i_x(i)));
    fprintf(fid_i_x_imag, '%d\n',imag(i_x(i)));
    fprintf(fid_i_y_real, '%d\n',real(i_y(i)));
    fprintf(fid_i_y_imag, '%d\n',imag(i_y(i)));
    fprintf(fid_i_twiddle_real,'%d\n',real(i_twiddle(i)));
    fprintf(fid_i_twiddle_imag,'%d\n',imag(i_twiddle(i)));
    fprintf(fid_o_x_real, '%d\n',real(o_x(i)));
    fprintf(fid_o_x_imag, '%d\n',imag(o_x(i)));
    fprintf(fid_o_y_real, '%d\n',real(o_y(i)));
    fprintf(fid_o_y_imag, '%d\n',imag(o_y(i)));
  end

 fclose all;
end



function [o_x,o_y] = my_butterfly(i_x,i_y,i_twiddle,NBT)
    o_x = floor((i_x+floor((i_y*i_twiddle)/2^(NBT-1)))/2);
    o_y = floor((i_x-floor((i_y*i_twiddle)/2^(NBT-1)))/2);
end
