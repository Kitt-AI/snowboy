import snowboydecoder_arecord
import sys
import signal

"""
This demo file shows you how to use the new_message_callback to interact with
the recorded audio after a keyword is spoken. It saves the recorded audio to a 
wav file.
"""


interrupted = False


def signal_handler(signal, frame):
    global interrupted
    interrupted = True

def audioRecorderCallback(fname):
	print ("call google to STT: " + fname)

def interrupt_callback():
	global interrupted
	return interrupted

if len(sys.argv) == 1:
    print("Error: need to specify model name")
    print("Usage: python demo.py your.model")
    sys.exit(-1)

model = sys.argv[1]

# capture SIGINT signal, e.g., Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

detector = snowboydecoder_arecord.HotwordDetector(model, sensitivity=0.5)
print('Listening... Press Ctrl+C to exit')

def audioRecorderCallback(fname):
	print ('file is complete ' + fname)

# main loop
detector.start( detected_callback=None, #snowboydecoder_arecord.play_audio_file,
               interrupt_check=interrupt_callback,
               audio_recorder_callback=audioRecorderCallback,
               sleep_time=0.01)

detector.terminate()
