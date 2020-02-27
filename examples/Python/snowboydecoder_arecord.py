#!/usr/bin/env python

import collections
import snowboydetect
import time
import wave
import os
import logging
import subprocess
import threading
import sys

logging.basicConfig()
logger = logging.getLogger("snowboy")
logger.setLevel(logging.INFO)


logging.getLogger().addHandler(logging.StreamHandler(sys.stdout))

TOP_DIR = os.path.dirname(os.path.abspath(__file__))

RESOURCE_FILE = os.path.join(TOP_DIR, "resources/common.res")
DETECT_DING = os.path.join(TOP_DIR, "resources/ding.wav")
DETECT_DONG = os.path.join(TOP_DIR, "resources/dong.wav")


class RingBuffer(object):
    """Ring buffer to hold audio from audio capturing tool"""
    def __init__(self, size = 4096):
        self._buf = collections.deque(maxlen=size)

    def extend(self, data):
        """Adds data to the end of buffer"""
        self._buf.extend(data)

    def get(self):
        """Retrieves data from the beginning of buffer and clears it"""
        tmp = bytes(bytearray(self._buf))
        self._buf.clear()
        return tmp

    def clear(self):
        self._buf.clear()


def play_audio_file(fname=DETECT_DING):
    """Simple callback function to play a wave file. By default it plays
    a Ding sound.

    :param str fname: wave file name
    :return: None
    """
    os.system("aplay " + fname + " > /dev/null 2>&1")

class HotwordDetector(object):
    """
    Snowboy decoder to detect whether a keyword specified by `decoder_model`
    exists in a microphone input stream.

    :param decoder_model: decoder model file path, a string or a list of strings
    :param resource: resource file path.
    :param sensitivity: decoder sensitivity, a float of a list of floats.
                              The bigger the value, the more senstive the
                              decoder. If an empty list is provided, then the
                              default sensitivity in the model will be used.
    :param audio_gain: multiply input volume by this factor.
    """
    def __init__(self, decoder_model,
                 resource=RESOURCE_FILE,
                 sensitivity=[],
                 audio_gain=1):

        tm = type(decoder_model)
        ts = type(sensitivity)
        if tm is not list:
            decoder_model = [decoder_model]
        if ts is not list:
            sensitivity = [sensitivity]
        model_str = ",".join(decoder_model)

        self.detector = snowboydetect.SnowboyDetect(
            resource_filename=resource.encode(), model_str=model_str.encode())
        self.detector.SetAudioGain(audio_gain)
        self.num_hotwords = self.detector.NumHotwords()

        if len(decoder_model) > 1 and len(sensitivity) == 1:
            sensitivity = sensitivity*self.num_hotwords
        if len(sensitivity) != 0:
            assert self.num_hotwords == len(sensitivity), \
                "number of hotwords in decoder_model (%d) and sensitivity " \
                "(%d) does not match" % (self.num_hotwords, len(sensitivity))
        sensitivity_str = ",".join([str(t) for t in sensitivity])
        if len(sensitivity) != 0:
            self.detector.SetSensitivity(sensitivity_str.encode())

        self.ring_buffer = RingBuffer(
            self.detector.NumChannels() * self.detector.SampleRate() * 5)

    def record_proc(self):
        CHUNK = 2048
        RECORD_RATE = 16000

        # per https://github.com/evancohen/sonus/pull/93/commits
        DEADMAX = 20

        while self.recording:
            dead_counter = 0
            cmd = 'arecord --device=plughw:1,0 -q -r %d -f S16_LE' % RECORD_RATE
            process = subprocess.Popen(cmd.split(' '),
                                       stdout = subprocess.PIPE,
                                       stderr = subprocess.PIPE)
            wav = wave.open(process.stdout, 'rb')
            while self.recording and dead_counter < DEADMAX:
                data = wav.readframes(CHUNK)
                if len(data) < 100:
                    dead_counter += 1
                self.ring_buffer.extend(data)
            process.terminate()

    def init_recording(self):
        """
        Start a thread for spawning arecord process and reading its stdout
        """
        self.recording = True
        self.record_thread = threading.Thread(target = self.record_proc)
        self.record_thread.start()

    def start(self, detected_callback=play_audio_file,
              interrupt_check=lambda: False,
              sleep_time=0.03,  
              audio_recorder_callback=None, 
              silent_count_threshold=3,    
              recording_timeout=100):
        """
        Start the voice detector. For every `sleep_time` second it checks the
        audio buffer for triggering keywords. If detected, then call
        corresponding function in `detected_callback`, which can be a single
        function (single model) or a list of callback functions (multiple
        models). Every loop it also calls `interrupt_check` -- if it returns
        True, then breaks from the loop and return.

        :param detected_callback: a function or list of functions. The number of
                                  items must match the number of models in
                                  `decoder_model`.
        :param interrupt_check: a function that returns True if the main loop
                                  needs to stop.
        :param float sleep_time: how much time in second every loop waits.
        :param audio_recorder_callback: if specified, this will be called after 
                                  a keyword has been spoken and after the 
                                  phrase immediately after the keyword has    
                                  been recorded. The function will be 
                                  passed the name of the file where the   
                                  phrase was recorded.    
        :param silent_count_threshold: indicates how long silence must be heard 
                                  to mark the end of a phrase that is  
                                  being recorded.  
        :param recording_time out: limits the maximum length of a recording.
        :return: None
        """

        self.init_recording()

        if interrupt_check():
            logger.debug("detect voice return")
            return

        tc = type(detected_callback)
        if tc is not list:
            detected_callback = [detected_callback]
        if len(detected_callback) == 1 and self.num_hotwords > 1:
            detected_callback *= self.num_hotwords

        assert self.num_hotwords == len(detected_callback), \
            "Error: hotwords in your models (%d) do not match the number of " \
            "callbacks (%d)" % (self.num_hotwords, len(detected_callback))

        logger.debug("detecting...")
        
        state = "PASSIVE"

        while True:
            

            if interrupt_check():
                logger.debug("detect voice break")
                break
            data = self.ring_buffer.get()
            if len(data) == 0:
                time.sleep(sleep_time)
                continue

            status = self.detector.RunDetection(data)
            if status == -1:
                logger.warning("Error initializing streams or reading audio data")

            if state == "PASSIVE":  
                print (state)

                if status > 0: #key word found  
                    self.recordedData = []  
                    self.recordedData.append(data)  
                    silentCount = 0 
                    recordingCount = 0
                    message = "Keyword " + str(status) + " detected at time: "
                    message += time.strftime("%Y-%m-%d %H:%M:%S",
                                             time.localtime(time.time()))
                    logger.info(message)
                    callback = detected_callback[status-1]
                    if callback is not None:
                        callback()

                    if audio_recorder_callback is not None:
                        state = "ACTIVE"
                        self.ring_buffer.clear()
                    continue

            elif state == "ACTIVE":
                print (silentCount)
                stopRecording = False
                
                # hard limit
                if recordingCount > recording_timeout:
                    stopRecording = True

                elif status == -2: #silence found
                    if silentCount > silent_count_threshold:
                        stopRecording = True
                    else:
                        silentCount = silentCount + 1
                elif status == 0: #voice found
                    silentCount = 0

                if stopRecording == True:
                    fname = self.saveMessage(data)
                    audio_recorder_callback(fname)
                    state = "PASSIVE"
                    continue

                recordingCount = recordingCount + 1
                self.recordedData.append(data)

        logger.debug("finished.")

    def saveMessage(self,data):
        logger.info("starting saveMessage")
        """
        Save the message stored in self.recordedData to a timestamped file.
        """
        filename = 'output' + str(int(time.time())) + '.wav'
        data = b''.join(self.recordedData)

        #use wave to save data
        wf = wave.open(filename, 'wb')
        wf.setnchannels(1)
        wf.setsampwidth(2)  # based on arecord settings, from above.
        print (self.detector.SampleRate())
        wf.setframerate(self.detector.SampleRate())
        wf.writeframes(data)
        wf.close()
        logger.debug("finished saving: " + filename)
        return filename

    def terminate(self):
        """
        Terminate audio stream. Users cannot call start() again to detect.
        :return: None
        """
        self.recording = False
        self.record_thread.join()
