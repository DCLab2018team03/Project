import scipy.io.wavfile as wav
import numpy as np

def ola (data, s, N, H_a):
    L = len(data)
    H_s = int (s*H_a)
    x = np.array( [data[i:i+N] for i in range(0,L-N,H_a)] ) 
    Hann_window = np.array([[0.5*(1-np.cos( 2*np.pi* (i+N//2) / (N-1) ))]*2 for i in range(-N//2, N//2)])

    new_data = np.zeros(((H_s*len(x)+N-H_s),2))
    for i in range(0, len(x)):
        new_data[i*H_s:i*H_s+N] += x[i] * Hann_window
    
    new_data = new_data.astype(np.int16)
    return new_data

def wsola (data, s, N, H_s, tolerance):
    L = len(data)
    H_a = int(H_s / s)
    
    Hann_window = np.array([0.5*(1-np.cos( 2*np.pi* (i+N//2) / (N-1) )) for i in range(-N//2, N//2)])

    delta_max = tolerance
    x = []
    for i in range(0, L-N-delta_max, H_a):
        if i == 0:
            x.append(data[0:N+H_s])
        else:
            if i-delta_max < 0:
                start = 0
            else:
                start = i-delta_max
            frame = data[start:i+delta_max+N+H_s]
            frame = np.pad(frame, (2*delta_max+N+H_s-len(frame), 0),'constant', constant_values=(0, 0))
            x.append(frame)
      
    x = np.array(x)
    new_x = []
    for i in range(0, len(x)):
        if i == 0:
            index = 0
        else:
            cross_correlation = np.correlate(
                    x[i][:-H_s], last_x)
            index = np.argmax(cross_correlation)
            
        new_x.append(x[i][index:index+N]*Hann_window)
        last_x = x[i][index+H_s:index+H_s+N]*Hann_window 
        
    new_x = np.array(new_x)

    new_data = np.zeros(H_s*len(new_x)+N-H_s)
    for i in range( 0, len(new_x)):
        new_data[i*H_s:i*H_s+N] += new_x[i]
    
    new_data = new_data.astype(np.int16)
    return new_data

sample_rate, ori_data = wav.read('k_1.wav')

s = 1.3 # stretching factor
N = 1024 # window_size
H_s = N//2 # original shift
tolerance = N//2
#new_data = ola(ori_data, s, N, H_a)

left  = wsola (ori_data[:,0], s, N, H_s, tolerance)
right = wsola (ori_data[:,1], s, N, H_s, tolerance)
new_data = np.zeros( (len(left), 2) , dtype = 'int16')
new_data[:,0] = left
new_data[:,1] = right

wav.write('test.wav', sample_rate, new_data)


