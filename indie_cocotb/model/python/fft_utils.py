import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

def butterfly(i_x, i_y, i_twiddle, NBT):
    i_y_twiddle = np.floor(np.real((i_y*i_twiddle)/2 ** (NBT-1))) + 1j * np.floor(np.imag((i_y*i_twiddle)/2 ** (NBT-1)))
    o_x = np.floor(np.real((i_x+i_y_twiddle)/2)) + 1j * np.floor(np.imag((i_x+i_y_twiddle)/2))
    o_y = np.floor(np.real((i_x-i_y_twiddle)/2)) + 1j * np.floor(np.imag((i_x-i_y_twiddle)/2))
    return o_x, o_y


def butterfly_vector_gen(NBD=8, NBT=8, L=512, seed=None):

    np.random.seed(seed)
    i_x_complex = np.random.uniform(0, 1, L) * np.exp(1.j * np.random.uniform(0, 2 * np.pi, L))
    i_y_complex = np.random.uniform(0, 1, L) * np.exp(1.j * np.random.uniform(0, 2 * np.pi, L))
    i_x  = sat(rnd(np.real(i_x_complex) * 2 ** (NBD-1)), NB=NBD) + 1j * sat(rnd(np.imag(i_x_complex) * 2 ** (NBD-1)), NB=NBD)
    i_y  = sat(rnd(np.real(i_y_complex) * 2 ** (NBD-1)), NB=NBD) + 1j * sat(rnd(np.imag(i_y_complex) * 2 ** (NBD-1)), NB=NBD)

    N = 65536
    tw = get_twiddles(N,NBT)
    
    i_twiddle = tw[np.random.randint(N/2,size=L)]
    o_x = np.zeros(L, dtype=np.complex128)
    o_y = np.zeros(L, dtype=np.complex128)

    # Vector dictionary
    v_d = {
        'i_x_real': [],
        'i_x_imag': [],
        'i_y_real': [],
        'i_y_imag': [],
        'i_twiddle_real': [],
        'i_twiddle_imag': [],
        'o_x_real': [],
        'o_x_imag': [],
        'o_y_real': [],
        'o_y_imag': []
    }

    for i in range(L):
        o_x[i], o_y[i] = butterfly(i_x[i], i_y[i], i_twiddle[i], NBT)
        v_d['i_x_real'].append(int(np.real(i_x[i])))
        v_d['i_x_imag'].append(int(np.imag(i_x[i])))
        v_d['i_y_real'].append(int(np.real(i_y[i])))
        v_d['i_y_imag'].append(int(np.imag(i_y[i])))
        v_d['i_twiddle_real'].append(int(np.real(i_twiddle[i])))
        v_d['i_twiddle_imag'].append(int(np.imag(i_twiddle[i])))
        v_d['o_x_real'].append(int(np.real(o_x[i])))
        v_d['o_x_imag'].append(int(np.imag(o_x[i])))
        v_d['o_y_real'].append(int(np.real(o_y[i])))
        v_d['o_y_imag'].append(int(np.imag(o_y[i])))
    
    return v_d


def bitrevorder(x):
    x_br=[]
    for idx, s in enumerate(x):
        br_idx = '{:0{width}b}'.format(idx, width=int(np.log2(len(x))))
        bidx = int(br_idx[::-1], 2)
        x_br.append(x[bidx])
    return x_br


def circshift(b,n): 
    idx=[(x+n)%len(b) for x in range(len(b))]
    c=[b[x] for x in idx]
    return c
    

def get_idx(btfly, stage, N):
    b=list(np.binary_repr(btfly*2, int(np.log2(N))))
    idx0=int(''.join(circshift(b,stage)),2)
    
    b=list(np.binary_repr(btfly*2+1, int(np.log2(N)))) 
    idx1=int(''.join(circshift(b,stage)),2)
    
    tidx = btfly & ((int(N/2-1)<<int(np.log2(N/2)) >> stage))    
    
    return idx0, idx1, tidx


def get_twiddles(N,NBT):
    tw  = np.exp(-2*np.pi*1j* np.arange(N)/float(N))
    twr = np.real(tw)
    twi = np.imag(tw)
    twr = np.floor(twr*2**(NBT-1)+0.5)
    twi = np.floor(twi*2**(NBT-1)+0.5)
    twr = (twr>2**(NBT-1)-1)*(2**(NBT-1)-1)+(twr<=2**(NBT-1)-1)*twr
    twi = (twi>2**(NBT-1)-1)*(2**(NBT-1)-1)+(twi<=2**(NBT-1)-1)*twi
    return twr + 1j * twi
    

def my_fft(x,debug=0,NB=8,NBT=8):
    N = len(x)
    
    # bitrevorder
    x=bitrevorder(x)
        
    # twiddle_gen
    tw = get_twiddles(N,NBT)                                      
    
    # FFT
    for stage in range(0,int(np.log2(N))):
        for btfly in range(0,int(N/2)):
            idx0,idx1,tidx= get_idx(btfly,stage,N)
            if debug:
                print("stage:",stage,"btfly:",btfly," - idx0:", idx0,"idx2:",idx1,"tidx:",tidx)
            x[idx0],x[idx1]=butterfly(i_x=x[idx0], i_y=x[idx1], i_twiddle=tw[tidx], NBT=NBT)
    return x


def gen_sin_data(start_time=0, end_time=1, sample_rate=512, theta=0, frequency=1e3, amplitude=1, graph=False):
    frequency = round(frequency)
    time = np.arange(start_time, end_time, 1/sample_rate)
    sinewave = amplitude * np.sin(2 * np.pi * frequency * time + theta)
    if graph:
        plt.figure(figsize=(20, 6), dpi=80)
        plt.plot(sinewave)
        plt.savefig(f"sine_{frequency}Hz.png")
    return sinewave


def rnd(x):
    return np.floor(x+0.5)


def sat(x,NB):    
    return (x>2**(NB-1)-1) * (2**(NB-1)-1-x) + (x<-2**(NB-1)) * (-2**(NB-1)-x) + x;    


def write_twiddle_rom(NFFT: int, NBT: int, directory: Path):
    f=open(directory / 'twiddle_rom.v','w')
    intro = '''module twiddle_rom
  (input  [%(NBSEL)s-1:0] i_sel,
   output signed [%(NBT)d-1:0]   o_twiddle_real,
   output signed [%(NBT)d-1:0]   o_twiddle_imag);
 
   wire signed [%(NBT)d-1:0] twiddle_real_rom [%(NFFT)d/2-1:0];
   wire signed [%(NBT)d-1:0] twiddle_imag_rom [%(NFFT)d/2-1:0];
 
   assign o_twiddle_real = twiddle_real_rom[i_sel];
   assign o_twiddle_imag = twiddle_imag_rom[i_sel];
\n'''%({'NBSEL':int(np.log2(NFFT/2)),'NBT':NBT,'NFFT':NFFT})
    f.write(intro)
    tw = get_twiddles(NFFT,NBT)
    
    for i in range(int(NFFT/2)):
        f.write('''   assign twiddle_real_rom[%(idx)d] = %(twr)d; \n'''%({'idx':i,'twr':int(np.real(tw[i]))}))
        f.write('''   assign twiddle_imag_rom[%(idx)d] = %(twi)d; \n'''%({'idx':i,'twi':int(np.imag(tw[i]))}))

    f.write('endmodule')
    f.close()
