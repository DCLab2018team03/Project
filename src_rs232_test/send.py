from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv, stdout
import string
import wave
import numpy as np

def wav_to_bytes(filename):
    f = wave.open(filename, "rb")
    params = f.getparams()
    _,_,_, nframes = params[:4]
    str_data = f.readframes(nframes)
    f.close()
    
    wave_data = np.fromstring(str_data, dtype=np.short)
    wave_data.shape = -1, 2
    wave_data = wave_data.T
    assert(len(wave_data[0]) == len(wave_data[1]))
    output = b''
    for k in range(len(wave_data[0])):
        left_bytes = wave_data[0][k].tobytes()
        right_bytes = wave_data[1][k].tobytes()
        out_data = bytes([left_bytes[0]])+bytes([left_bytes[1]])+bytes([right_bytes[0]])+bytes([right_bytes[1]])
        output = output+out_data
    return bytes([len(output)]),output

if len(argv) != 3:
    print("Usage: {} COM[number] [wave file]")
    exit()
s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)

header, data = wav_to_bytes(argv[2])
s.write(header) # write header
s.write(data)