import scipy.io.wavfile as wav
import numpy as np
import math
sample_rate1, ori_data1 = wav.read('lemon.wav')
sample_rate2, ori_data2 = wav.read('may.wav')
sample_rate3, ori_data3 = wav.read('ite.wav')


new_data = (ori_data1/3 + ori_data2/3 + ori_data3/3)
new_data.setflags(write=1)
print(new_data)

#for i in range(0, len(ori_data1)-2, 3):
#  new_data[i, 0] = ori_data2[i, 0]
#  new_data[i, 1] = ori_data2[i, 1]
#  new_data[i+1, 0] = ori_data3[i+1, 0]
#  new_data[i+1, 1] = ori_data3[i+1, 1]

new_data = new_data.astype(np.int16)
print(new_data)


wav.write('test.wav', sample_rate1, new_data)