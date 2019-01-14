import wave
import sys
music = open("DAOKO.wav", 'rb')

f = open("transformed", 'wb')
data = music.read()
print(data[0:44])
f.write(data[44:])

