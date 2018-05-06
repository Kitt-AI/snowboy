#!/usr/bin/env python3
from snowboy import snowboydecoder
import sys
import signal
import os

interrupted = False


def signal_handler(signal, frame):
    global interrupted
    interrupted = True


def interrupt_callback():
    global interrupted
    return interrupted

if len(sys.argv) != 2:
    print("Error: need to specify 1 model name")
    print("Usage: python demo.py your.model")
    sys.exit(-1)

def main():
    model = sys.argv[1]
    if not os.path.isfile(model):
        print("Error: Not a valid model.")
        sys.exit(-1)

    # capture SIGINT signal, e.g., Ctrl+C
    signal.signal(signal.SIGINT, signal_handler)

    detector = snowboydecoder.HotwordDetector(model, sensitivity=0.5, apply_frontend=True)
    print('Listening... Press Ctrl+C to exit')

    # main loop
    detector.start(detected_callback=snowboydecoder.play_audio_file,
                   interrupt_check=interrupt_callback,
                   sleep_time=0.03)

    detector.terminate()

if __name__ == "__main__":
    main()
