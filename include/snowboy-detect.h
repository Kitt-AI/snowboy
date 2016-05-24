// include/snowboy-detect.h

// Copyright 2016  KITT.AI (author: Guoguo Chen)

#ifndef SNOWBOY_INCLUDE_SNOWBOY_DETECT_H_
#define SNOWBOY_INCLUDE_SNOWBOY_DETECT_H_

#include <memory>
#include <string>

namespace snowboy {

// Forward declaration.
struct WaveHeader;
class PipelineDetect;

////////////////////////////////////////////////////////////////////////////////
//
// SnowboyDetect class interface.
//
////////////////////////////////////////////////////////////////////////////////
class SnowboyDetect {
 public:
  // Constructor that takes a resource file, and a list of hotword models which
  // are separated by comma. In the case that more than one hotword exist in the
  // provided models, RunDetection() will return the index of the hotword, if
  // the corresponding hotword is triggered.
  //
  // CAVEAT: a personal model only contain one hotword, but an universal model
  //         may contain multiple hotwords. It is your responsibility to figure
  //         out the index of the hotword. For example, if your model string is
  //         "foo.pmdl,bar.umdl", where foo.pmdl contains hotword x, bar.umdl
  //         has two hotwords y and z, the indices of different hotwords are as
  //         follows:
  //         x 1
  //         y 2
  //         z 3
  //
  // @param [in]  resource_filename   Filename of resource file.
  // @param [in]  model_str           A string of multiple hotword models,
  //                                  separated by comma.
  SnowboyDetect(const std::string& resource_filename,
                const std::string& model_str);

  // Resets the detection. This class handles voice activity detection (VAD)
  // internally. But if you have an external VAD, you should call Reset()
  // whenever you see segment end from your VAD.
  bool Reset();

  // Runs hotword detection. Supported audio format is WAVE (with linear PCM,
  // 8-bits unsigned integer, 16-bits signed integer or 32-bits signed integer).
  // See SampleRate(), NumChannels() and BitsPerSample() for the required
  // sampling rate, number of channels and bits per sample values. You are
  // supposed to provide a small chunk of data (e.g., 0.1 second) each time you
  // call RunDetection(). Larger chunk usually leads to longer delay, but less
  // CPU usage.
  //
  // Definition of return values:
  // -2: Silence.
  // -1: Error.
  //  0: No event.
  //  1: Hotword 1 triggered.
  //  2: Hotword 2 triggered.
  //  ...
  //
  //  @param [in]  data               Small chunk of data to be detected. See
  //                                  above for the supported data format.
  int RunDetection(const std::string& data);

  // Various versions of RunDetection() that take different format of audio. If
  // NumChannels() > 1, e.g., NumChannels() == 2, then the array is as follows:
  //
  //   d1c1, d1c2, d2c1, d2c2, d3c1, d3c2, ..., dNc1, dNc2
  //
  // where d1c1 means data point 1 of channel 1.
  //
  // @param [in]  data               Small chunk of data to be detected. See
  //                                 above for the supported data format.
  // @param [in]  array_length       Length of the data array.
  int RunDetection(const float* const data, const int array_length);
  int RunDetection(const int16_t* const data, const int array_length);
  int RunDetection(const int32_t* const data, const int array_length);

  // Sets the sensitivity string for the loaded hotwords. A <sensitivity_str> is
  // a list of floating numbers between 0 and 1, and separated by comma. For
  // example, if there are 3 loaded hotwords, your string should looks something
  // like this:
  //   0.4,0.5,0.8
  // Make sure you properly align the sensitivity value to the corresponding
  // hotword.
  void SetSensitivity(const std::string& sensitivity_str);

  // Returns the sensitivity string for the current hotwords.
  std::string GetSensitivity() const;

  // Applied a fixed gain to the input audio. In case you have a very weak
  // microphone, you can use this function to boost input audio level.
  void SetAudioGain(const float audio_gain);

  // Writes the models to the model filenames specified in <model_str> in the
  // constructor. This overwrites the original model with the latest parameter
  // setting. You are supposed to call this function if you have updated the
  // hotword sensitivities through SetSensitivity(), and you would like to store
  // those values in the model as the default value.
  void UpdateModel() const;

  // Returns the number of the loaded hotwords. This helps you to figure the
  // index of the hotwords.
  int NumHotwords() const;

  // Returns the required sampling rate, number of channels and bits per sample
  // values for the audio data. You should use this information to set up your
  // audio capturing interface.
  int SampleRate() const;
  int NumChannels() const;
  int BitsPerSample() const;

  ~SnowboyDetect();

 private:
  std::unique_ptr<WaveHeader> wave_header_;
  std::unique_ptr<PipelineDetect> detect_pipeline_;
};

}  // namespace snowboy

#endif  // SNOWBOY_INCLUDE_SNOWBOY_DETECT_H_
