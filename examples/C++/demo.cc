// example/C++/demo.cc

// Copyright 2016  KITT.AI (author: Guoguo Chen)

#include <cassert>
#include <csignal>
#include <iostream>
#include <pa_ringbuffer.h>
#include <pa_util.h>
#include <portaudio.h>
#include <string>
#include <vector>

#include "include/snowboy-detect.h"

int PortAudioCallback(const void* input,
                      void* output,
                      unsigned long frame_count,
                      const PaStreamCallbackTimeInfo* time_info,
                      PaStreamCallbackFlags status_flags,
                      void* user_data);

class PortAudioWrapper {
 public:
  // Constructor.
  PortAudioWrapper(int sample_rate, int num_channels, int bits_per_sample) {
    num_lost_samples_ = 0;
    min_read_samples_ = sample_rate * 0.1;
    Init(sample_rate, num_channels, bits_per_sample);
  }

  // Reads data from ring buffer.
  template<typename T>
  void Read(std::vector<T>* data) {
    assert(data != NULL);

    // Checks ring buffer overflow.
    if (num_lost_samples_ > 0) {
      std::cerr << "Lost " << num_lost_samples_ << " samples due to ring"
          << " buffer overflow." << std::endl;
      num_lost_samples_ = 0;
    }

    ring_buffer_size_t num_available_samples = 0;
    while (true) {
      num_available_samples =
          PaUtil_GetRingBufferReadAvailable(&pa_ringbuffer_);
      if (num_available_samples >= min_read_samples_) {
        break;
      }
      Pa_Sleep(5);
    }

    // Reads data.
    num_available_samples = PaUtil_GetRingBufferReadAvailable(&pa_ringbuffer_);
    data->resize(num_available_samples);
    ring_buffer_size_t num_read_samples = PaUtil_ReadRingBuffer(
        &pa_ringbuffer_, data->data(), num_available_samples);
    if (num_read_samples != num_available_samples) {
      std::cerr << num_available_samples << " samples were available,  but "
          << "only " << num_read_samples << " samples were read." << std::endl;
    }
  }

  int Callback(const void* input, void* output,
               unsigned long frame_count,
               const PaStreamCallbackTimeInfo* time_info,
               PaStreamCallbackFlags status_flags) {
    // Input audio.
    ring_buffer_size_t num_written_samples =
        PaUtil_WriteRingBuffer(&pa_ringbuffer_, input, frame_count);
    num_lost_samples_ += frame_count - num_written_samples;
    return paContinue;
  }

  ~PortAudioWrapper() {
    Pa_StopStream(pa_stream_);
    Pa_CloseStream(pa_stream_);
    Pa_Terminate();
    PaUtil_FreeMemory(ringbuffer_);
  }

 private:
  // Initialization.
  bool Init(int sample_rate, int num_channels, int bits_per_sample) {
    // Allocates ring buffer memory.
    int ringbuffer_size = 16384;
    ringbuffer_ = static_cast<char*>(
        PaUtil_AllocateMemory(bits_per_sample / 8 * ringbuffer_size));
    if (ringbuffer_ == NULL) {
      std::cerr << "Fail to allocate memory for ring buffer." << std::endl;
      return false;
    }

    // Initializes PortAudio ring buffer.
    ring_buffer_size_t rb_init_ans =
        PaUtil_InitializeRingBuffer(&pa_ringbuffer_, bits_per_sample / 8,
                                    ringbuffer_size, ringbuffer_);
    if (rb_init_ans == -1) {
      std::cerr << "Ring buffer size is not power of 2." << std::endl;
      return false;
    }

    // Initializes PortAudio.
    PaError pa_init_ans = Pa_Initialize();
    if (pa_init_ans != paNoError) {
      std::cerr << "Fail to initialize PortAudio, error message is \""
          << Pa_GetErrorText(pa_init_ans) << "\"" << std::endl;
      return false;
    }

    PaError pa_open_ans;
    if (bits_per_sample == 8) {
      pa_open_ans = Pa_OpenDefaultStream(
          &pa_stream_, num_channels, 0, paUInt8, sample_rate,
          paFramesPerBufferUnspecified, PortAudioCallback, this);
    } else if (bits_per_sample == 16) {
      pa_open_ans = Pa_OpenDefaultStream(
          &pa_stream_, num_channels, 0, paInt16, sample_rate,
          paFramesPerBufferUnspecified, PortAudioCallback, this);
    } else if (bits_per_sample == 32) {
      pa_open_ans = Pa_OpenDefaultStream(
          &pa_stream_, num_channels, 0, paInt32, sample_rate,
          paFramesPerBufferUnspecified, PortAudioCallback, this);
    } else {
      std::cerr << "Unsupported BitsPerSample: " << bits_per_sample
          << std::endl;
      return false;
    }
    if (pa_open_ans != paNoError) {
      std::cerr << "Fail to open PortAudio stream, error message is \""
          << Pa_GetErrorText(pa_open_ans) << "\"" << std::endl;
      return false;
    }

    PaError pa_stream_start_ans = Pa_StartStream(pa_stream_);
    if (pa_stream_start_ans != paNoError) {
      std::cerr << "Fail to start PortAudio stream, error message is \""
          << Pa_GetErrorText(pa_stream_start_ans) << "\"" << std::endl;
      return false;
    }
    return true;
  }

 private:
  // Pointer to the ring buffer memory.
  char* ringbuffer_;

  // Ring buffer wrapper used in PortAudio.
  PaUtilRingBuffer pa_ringbuffer_;

  // Pointer to PortAudio stream.
  PaStream* pa_stream_;

  // Number of lost samples at each Read() due to ring buffer overflow.
  int num_lost_samples_;

  // Wait for this number of samples in each Read() call.
  int min_read_samples_;
};

int PortAudioCallback(const void* input,
                      void* output,
                      unsigned long frame_count,
                      const PaStreamCallbackTimeInfo* time_info,
                      PaStreamCallbackFlags status_flags,
                      void* user_data) {
  PortAudioWrapper* pa_wrapper = reinterpret_cast<PortAudioWrapper*>(user_data);
  pa_wrapper->Callback(input, output, frame_count, time_info, status_flags);
  return paContinue;
}

void SignalHandler(int signal){
  std::cerr << "Caught signal " << signal << ", terminating..." << std::endl;
  exit(0);
}

int main(int argc, char* argv[]) {
  std::string usage =
      "Example that shows how to use Snowboy in C++. Parameters are\n"
      "hard-coded in the parameter section. Please check the source code for\n"
      "more details. Audio is captured by PortAudio.\n"
      "\n"
      "To run the example:\n"
      "  ./demo\n";

  // Checks the command.
  if (argc > 1) {
    std::cerr << usage;
    exit(1);
  }

  // Configures signal handling.
   struct sigaction sig_int_handler;
   sig_int_handler.sa_handler = SignalHandler;
   sigemptyset(&sig_int_handler.sa_mask);
   sig_int_handler.sa_flags = 0;
   sigaction(SIGINT, &sig_int_handler, NULL);

  // Parameter section.
  // If you have multiple hotword models (e.g., 2), you should set
  // <model_filename> and <sensitivity_str> as follows:
  //   model_filename =
  //     "resources/models/snowboy.umdl,resources/models/smart_mirror.umdl";
  //   sensitivity_str = "0.5,0.5";
  std::string resource_filename = "resources/common.res";
  std::string model_filename = "resources/models/snowboy.umdl";
  std::string sensitivity_str = "0.5";
  float audio_gain = 1;
  bool apply_frontend = false;

  // Initializes Snowboy detector.
  snowboy::SnowboyDetect detector(resource_filename, model_filename);
  detector.SetSensitivity(sensitivity_str);
  detector.SetAudioGain(audio_gain);
  detector.ApplyFrontend(apply_frontend);

  // Initializes PortAudio. You may use other tools to capture the audio.
  PortAudioWrapper pa_wrapper(detector.SampleRate(),
                              detector.NumChannels(), detector.BitsPerSample());

  // Runs the detection.
  // Note: I hard-coded <int16_t> as data type because detector.BitsPerSample()
  //       returns 16.
  std::cout << "Listening... Press Ctrl+C to exit" << std::endl;
  std::vector<int16_t> data;
  while (true) {
    pa_wrapper.Read(&data);
    if (data.size() != 0) {
      int result = detector.RunDetection(data.data(), data.size());
      if (result > 0) {
        std::cout << "Hotword " << result << " detected!" << std::endl;
      }
    }
  }

  return 0;
}
