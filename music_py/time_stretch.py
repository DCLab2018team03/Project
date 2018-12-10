import scipy.io.wavfile as wav
import numpy as np
import math

sample_rate, ori_data = wav.read('k_1.wav')

L = len(ori_data) # original audio length
s = 1.5 # stretching factor
N = 512 # window_size
H_a = 256 # original shift
H_s = int(s * H_a) # new shift     

x = np.array( [ori_data[i:i+N] for i in range(0,L-N,H_a)] ) 
Hann_window = np.array([[0.5*(1-math.cos( 2*np.pi* (i+N//2) / (N-1) ))]*2 for i in range(-N//2, N//2)])

new_data = np.zeros(((H_s*len(x)+N-H_s),2))
new_data = new_data.astype(np.int16)
for i in range( 0, len(x)):
    new_data[i*H_s:i*H_s+N] = new_data[i*H_s:i*H_s+N] + x[i] * Hann_window
new_data = new_data.astype(np.int16)

wav.write('test.wav', sample_rate, new_data)


