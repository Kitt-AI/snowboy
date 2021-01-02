#!/usr/bin/env python3
from __future__ import print_function
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

def main():
    if len(sys.argv) < 2:
        print("Using default alexa model.")
        model = os.path.join(snowboydecoder.TOP_DIR, 'resources/alexa/alexa-avs-sample-app/alexa.umdl')
    elif len(sys.argv) > 2:
        print("Error: need to specify 1 model name")
        print("Usage: python demo.py your.model")
        sys.exit(-1)
    else:
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
