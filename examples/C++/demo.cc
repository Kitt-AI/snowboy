// example/C++/demo.cc

// Copyright 2016  KITT.AI (author: Guoguo Chen)

#include <cassert>
#include <csignal>
#include <iostream>
#include <portaudio.h>
#include <string>
#include <vector>
#include <boost/lockfree/spsc_queue.hpp>

#include "include/snowboy-detect.h"

#define BUFFER_SIZE (1 << 14)

template<typename T>
int PortAudioCallback(const void* input,
                      void* output,
                      unsigned long frame_count,
                      const PaStreamCallbackTimeInfo* time_info,
                      PaStreamCallbackFlags status_flags,
                      void* user_data);

template<typename T>
class PortAudioWrapper {
 public:
  // Constructor.
  PortAudioWrapper(int sample_rate, int num_channels, int bits_per_sample) {
    num_lost_samples_ = 0;
    min_read_samples_ = sample_rate * 0.1;
    Init(sample_rate, num_channels, bits_per_sample);
  }

  // Reads data from ring buffer.
  size_t Read(std::vector<T>* data) {
    assert(data != NULL);

    // Checks ring buffer overflow.
    if (num_lost_samples_ > 0) {
      std::cerr << "Lost " << num_lost_samples_ << " samples due to ring"
          << " buffer overflow." << std::endl;
      num_lost_samples_ = 0;
    }

    size_t num_available_samples = 0;
    while (true) {
      // Reads data.
      size_t num_read_samples = ringbuffer_.pop(data->data() + num_available_samples, data->size() - num_available_samples);
      num_available_samples += num_read_samples;
      if (num_available_samples >= min_read_samples_) {
        break;
      }
      Pa_Sleep(5);
    }
    return num_available_samples;
  }

  int Callback(const void* input, void* output,
               unsigned long frame_count,
               const PaStreamCallbackTimeInfo* time_info,
               PaStreamCallbackFlags status_flags) {
    // Input audio.
    size_t num_written_samples = ringbuffer_.push(static_cast<const int16_t*>(input), frame_count);
    num_lost_samples_ += frame_count - num_written_samples;
    return paContinue;
  }

  ~PortAudioWrapper() {
    Pa_StopStream(pa_stream_);
    Pa_CloseStream(pa_stream_);
    Pa_Terminate();
  }

 private:
  // Initialization.
  bool Init(int sample_rate, int num_channels, int bits_per_sample) {
    std::cout << "Initializing PA with " << sample_rate << " sample rate, "
              << num_channels << " channels, " << bits_per_sample << " bps" << std::endl;
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
          paFramesPerBufferUnspecified, PortAudioCallback<T>, this);
    } else if (bits_per_sample == 16) {
      pa_open_ans = Pa_OpenDefaultStream(
          &pa_stream_, num_channels, 0, paInt16, sample_rate,
          paFramesPerBufferUnspecified, PortAudioCallback<T>, this);
    } else if (bits_per_sample == 32) {
      pa_open_ans = Pa_OpenDefaultStream(
          &pa_stream_, num_channels, 0, paInt32, sample_rate,
          paFramesPerBufferUnspecified, PortAudioCallback<T>, this);
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
  // Ring buffer wrapper used in PortAudio.
  boost::lockfree::spsc_queue<T, boost::lockfree::capacity<BUFFER_SIZE>> ringbuffer_;

  // Pointer to PortAudio stream.
  PaStream* pa_stream_;

  // Number of lost samples at each Read() due to ring buffer overflow.
  int num_lost_samples_;

  // Wait for this number of samples in each Read() call.
  int min_read_samples_;
};

template<typename T>
int PortAudioCallback(const void* input,
                      void* output,
                      unsigned long frame_count,
                      const PaStreamCallbackTimeInfo* time_info,
                      PaStreamCallbackFlags status_flags,
                      void* user_data) {
  PortAudioWrapper<T>* pa_wrapper = reinterpret_cast<PortAudioWrapper<T>*>(user_data);
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
  //   model_filename = "resources/snowboy.umdl,resources/alexa.pmdl";
  //   sensitivity_str = "0.4,0.4";
  std::string resource_filename = "resources/common.res";
  std::string model_filename = "resources/snowboy.umdl";
  std::string sensitivity_str = "0.5";
  float audio_gain = 1;

  // Initializes Snowboy detector.
  snowboy::SnowboyDetect detector(resource_filename, model_filename);
  detector.SetSensitivity(sensitivity_str);
  detector.SetAudioGain(audio_gain);

  // Initializes PortAudio. You may use other tools to capture the audio.
  // Note: I hard-coded <int16_t> as data type because detector.BitsPerSample()
  //       returns 16.
  PortAudioWrapper<int16_t> pa_wrapper(detector.SampleRate(),
                                       detector.NumChannels(), detector.BitsPerSample());

  // Runs the detection.
  std::cout << "Listening... Press Ctrl+C to exit" << std::endl;
  std::vector<int16_t> data(BUFFER_SIZE);
  while (true) {
    const size_t num_samples = pa_wrapper.Read(&data);
    if (num_samples) {
      int result = detector.RunDetection(data.data(), num_samples);
      if (result > 0) {
        std::cout << "Hotword " << result << " detected!" << std::endl;
      }
    }
  }

  return 0;
}
