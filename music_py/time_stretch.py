import scipy.io.wavfile as wav
import numpy as np

def ola (data, s, N, H_a):
    L = len(data)
    H_s = int (s*H_a)
    x = np.array( [ori_data[i:i+N] for i in range(0,L-N,H_a)] ) 
    Hann_window = np.array([[0.5*(1-np.cos( 2*np.pi* (i+N//2) / (N-1) ))]*2 for i in range(-N//2, N//2)])

    new_data = np.zeros(((H_s*len(x)+N-H_s),2))
    for i in range(0, len(x)):
        new_data[i*H_s:i*H_s+N] += x[i] * Hann_window
    
    new_data = new_data.astype(np.int16)
    return new_data

def wsola (data, s, N, H_a):
    L = len(data)
    delta_max = 256
    H_s = int (s*H_a)

    x = []
    for i in range(0, L-N-H_s-delta_max, H_a):
        if i == 0:
            x.append(data[0:N])
            last_x = data[i+H_s:i+H_s+N]
        else:
            try_x = np.correlate(
                data[i:i+N-H_s],
                last_x)
            index = np.argmax(try_x)
            best_x = data[i+index:i+index+N]
            x.append(best_x)
            last_x = data[i+index+H_s:i+index+H_s+N]

    x = np.array(x)
    Hann_window = np.array([0.5*(1-np.cos( 2*np.pi* (i+N//2) / (N-1) )) for i in range(-N//2, N//2)])
    new_data = np.zeros((H_s*len(x)+N-H_s))
    for i in range( 0, len(x)):
        new_data[i*H_s:i*H_s+N] += x[i] * Hann_window
    
    new_data = new_data.astype(np.int16)
    return new_data

def vocoder (data, s, N, H_a, sample_rate):
    x = np.array( [data[i:i+N] for i in range(0, len(data)-N,H_a)] ) 
    H_s = int(s*H_a)
    phase = np.zeros(N)
    hanning = np.hanning(N)
    result = np.zeros( H_s*len(x)+N-H_s , dtype = 'complex128')

    for i in np.arange(0, len(x)-1):
        a1 = x[i]
        a2 = x[i+1]
        s1 = np.fft.fft(a1)
        s2 = np.fft.fft(a2)
        
        phase = (phase + np.angle(s2/s1))
        s2_rephased = np.fft.ifft(np.abs(s2)*np.exp(1j*phase))
        result[i*H_s: i*H_s+N] += hanning * s2_rephased
    
    new_data = result.astype(np.int16)
    return new_data


if __name__ == "__main__":
    sample_rate, ori_data = wav.read('DAOKO.wav')

    s = 1.3 # stretching factor
    N = 512 # window_size
    H_a = 256 # original shift

    #new_data = ola (ori_data, s, N, H_a)
    
    left  = wsola (ori_data[:,0], s, N, H_a)
    right = wsola (ori_data[:,1], s, N, H_a)
    new_data = np.zeros( (len(left), 2) , dtype = 'int16')
    new_data[:,0] = left
    new_data[:,1] = right

    #left  = vocoder (ori_data[:,0], s, N, H_a, sample_rate)
    #right = vocoder (ori_data[:,1], s, N, H_a, sample_rate)
    #new_data = np.zeros( (len(left), 2) , dtype = 'int16')
    #new_data[:,0] = left
    #new_data[:,1] = right

    wav.write('test.wav', sample_rate, new_data)


