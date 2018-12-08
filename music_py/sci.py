import scipy.io.wavfile as wav
import numpy as np
import math
sample_rate, ori_data = wav.read('k_1.wav')
#ori_data = np.array([[1,2],[3,4],[5,6],[7,8],[9,10],[11,12],[13,14],[15,16],[17,18],[19,20]]*4)
N = len(ori_data)
print(N)
#X = np.arange(0, 2*N, 2)
#X_new = np.arange(2*N-1)       # Where you want to interpolate
#new_data = np.repeat(ori_data, 2, axis=0)
window_size = 2053
half_window_size = (window_size - 1)//2
speed = 1.5
shift = int((window_size-1)/2*speed)
overlap = window_size - shift
new_data = np.array(ori_data[0:shift],dtype=int)
fade_out = np.array([[i/overlap, i/overlap] for i in range(overlap,-1,-1)])
#fade_out = np.array([[0.5*(1-math.cos(3.141592653*i/overlap))]*2 for i in range(overlap, 2*overlap+1)])
fade_in = np.array([[i/overlap, i/overlap] for i in range(overlap+1)])
#fade_in = np.array([[0.5*(1-math.cos(3.141592653*i/overlap))]*2 for i in range(0, overlap+1)])
print(fade_in)
print(fade_out)
for i in range( half_window_size, N-half_window_size, half_window_size):
  new_data = np.append(new_data, ori_data[i+shift-half_window_size:i+shift-half_window_size+overlap+1]*fade_out+
                                 ori_data[i:i+overlap+1]*fade_in, axis=0)
  #print(i)
  #print(ori_data[i+shift-half_window_size:i+shift-half_window_size+overlap+1]*fade_out+
  #                               ori_data[i:i+overlap+1]*fade_in)
  new_data = np.append(new_data, ori_data[i+overlap+1:i+window_size],axis=0)
new_data = new_data.astype(int)
new_data = new_data.astype(np.int16)
with open('asdf', 'w') as outfile:
    for i in range(len(fade_in)):
        outfile.write("{} [{} {}]\n".format(i,fade_in[i][0], fade_in[i][1]))
print(new_data)
wav.write('test.wav', sample_rate, new_data)