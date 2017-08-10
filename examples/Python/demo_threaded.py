import snowboythreaded
import sys
import signal
import time

stop_program = False

# This a demo that shows running Snowboy in another thread


def signal_handler(signal, frame):
    global stop_program
    stop_program = True


if len(sys.argv) == 1:
    print("Error: need to specify model name")
    print("Usage: python demo4.py your.model")
    sys.exit(-1)

model = sys.argv[1]

# capture SIGINT signal, e.g., Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

# Initialize ThreadedDetector object and start the detection thread
threaded_detector = snowboythreaded.ThreadedDetector(model, sensitivity=0.5)
threaded_detector.start()

print('Listening... Press Ctrl+C to exit')

# main loop
threaded_detector.start_recog(sleep_time=0.03)

# Let audio initialization happen before requesting input
time.sleep(1)

# Do a simple task separate from the detection - addition of numbers
while not stop_program:
    try:
        num1 = int(raw_input("Enter the first number to add: "))
        num2 = int(raw_input("Enter the second number to add: "))
        print "Sum of number: {}".format(num1 + num2)
    except ValueError:
        print "You did not enter a number."

threaded_detector.terminate()
