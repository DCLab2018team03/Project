import wave
import numpy as np
import scipy.io.wavfile as wav
import sys
 
def flip(num):
    s = bin(num)[2:]
    arr = []
    for k in s:
        arr.append(1 if k=='1' else 0)
    out = 0
    for i in range(len(arr)):
        out += (1<<i)*arr[i]
    return out

def seven(num):
    if num >= 0x70:
        return (num&0xf)+0xf0
    else:
        return num

def rev_seven(num):
    if num >= 0xf0:
        return (num&0xf)+0x70
    else:
        return num

def wav_to_bytes(filename):
    print(filename)
    f = wave.open(filename+".wav", "rb")
    params = f.getparams()
    _, _, _, nframes = params[:4]
    str_data = f.readframes(nframes)
    f.close()
    
    wave_data = np.fromstring(str_data, dtype=np.short)
    wave_data.shape = -1, 2
    wave_data = wave_data.T
    with open("miku/"+filename+".data", 'wb') as ofile:
        assert(len(wave_data[0]) == len(wave_data[1]))
        ofile.write((len(wave_data[0])//2).to_bytes(4,'little'))
        for k in range(len(wave_data[0])):
            if k%0x200==0x200-2:
                ofile.write(b'\x00'*(0xc00))
            if k%2==1:
                continue
            left_bytes = wave_data[0][k].tobytes()
            right_bytes = wave_data[1][k].tobytes()
            out_data = bytes([left_bytes[0]])+bytes([rev_seven(left_bytes[1])])+bytes([right_bytes[0]])+bytes([rev_seven(right_bytes[1])])
            ofile.write(out_data)

def bytes_to_wav(filename):
    with open(filename, 'rb') as infile:
        k = infile.read()
        small = np.zeros(0x400, dtype='int8')
        data = np.zeros(0x400, dtype='int8')
        for big in range(len(k)//0x1000):
            for little in range(0,0x400,2):
                small[little], small[little+1] = k[big*0x1000+little],seven(k[big*0x1000+little+1])
            if big == 0:
                data = small+data
            else:
                data = np.append(data, small)
        with open("tmp", 'wb') as outfile:
            outfile.write(data)
    arr = np.fromfile('tmp', dtype='int16')
    
    if len(arr)%2:
        arr = arr[:-1]
    arr = arr.reshape(-1,2)
    print(arr)
    wav.write('output.wav', 32000, arr)

if __name__=="__main__":
    k = ["bass_b", "bass_d", "bass_e", "c", "e", "b", "clap", "ga", "kick"]
    for l in k:
        wav_to_bytes(l)
    #bytes_to_wav("love")
    #wav_to_bytes("k_mom_long_2")