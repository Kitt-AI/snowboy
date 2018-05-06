import snowboydecoder
import sys
import wave

# Demo code for detecting hotword in a .wav file
# Example Usage:
#  $ python demo3.py resources/snowboy.wav resources/models/snowboy.umdl
# Should print:
#  Hotword Detected!
#
#  $ python demo3.py resources/ding.wav resources/models/snowboy.umdl
# Should print:
#  Hotword Not Detected!


if len(sys.argv) != 3:
    print("Error: need to specify wave file name and model name")
    print("Usage: python demo3.py wave_file model_file")
    sys.exit(-1)

wave_file = sys.argv[1]
model_file = sys.argv[2]

f = wave.open(wave_file)
assert f.getnchannels() == 1, "Error: Snowboy only supports 1 channel of audio (mono, not stereo)"
assert f.getframerate() == 16000, "Error: Snowboy only supports 16K sampling rate"
assert f.getsampwidth() == 2, "Error: Snowboy only supports 16bit per sample"
data = f.readframes(f.getnframes())
f.close()

sensitivity = 0.5
detection = snowboydecoder.HotwordDetector(model_file, sensitivity=sensitivity)

ans = detection.detector.RunDetection(data)

if ans == 1:
    print('Hotword Detected!')
else:
    print('Hotword Not Detected!')

