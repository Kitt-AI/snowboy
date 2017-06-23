// snowboy-detect-c-wrapper.cc

// Copyright 2017  KITT.AI (author: Guoguo Chen)

#include <assert.h>

#include "snowboy-detect-c-wrapper.h"
#include "include/snowboy-detect.h"

extern "C" {
  SnowboyDetect* SnowboyDetectConstructor(const char* const resource_filename,
                                          const char* const model_str) {
    return reinterpret_cast<SnowboyDetect*>(
        new snowboy::SnowboyDetect(resource_filename, model_str));
  }

  bool SnowboyDetectReset(SnowboyDetect* detector) {
    assert(detector != NULL);
    return reinterpret_cast<snowboy::SnowboyDetect*>(detector)->Reset();
  }

  int SnowboyDetectRunDetection(SnowboyDetect* detector,
                                const int16_t* const data,
                                const int array_length, bool is_end) {
    assert(detector != NULL);
    assert(data != NULL);
    return reinterpret_cast<snowboy::SnowboyDetect*>(
        detector)->RunDetection(data, array_length, is_end);
  }

  void SnowboyDetectSetSensitivity(SnowboyDetect* detector,
                                   const char* const sensitivity_str) {
    assert(detector != NULL);
    reinterpret_cast<snowboy::SnowboyDetect*>(
        detector)->SetSensitivity(sensitivity_str);
  }

  void SnowboyDetectSetAudioGain(SnowboyDetect* detector,
                                 const float audio_gain) {
    assert(detector != NULL);
    reinterpret_cast<snowboy::SnowboyDetect*>(
        detector)->SetAudioGain(audio_gain);
  }

  void SnowboyDetectUpdateModel(SnowboyDetect* detector) {
    assert(detector != NULL);
    reinterpret_cast<snowboy::SnowboyDetect*>(detector)->UpdateModel();
  }

  void SnowboyDetectApplyFrontend(SnowboyDetect* detector,
                                  const bool apply_frontend) {
    assert(detector != NULL);
    reinterpret_cast<snowboy::SnowboyDetect*>(
        detector)->ApplyFrontend(apply_frontend);
  }

  int SnowboyDetectNumHotwords(SnowboyDetect* detector) {
    assert(detector != NULL);
    return reinterpret_cast<snowboy::SnowboyDetect*>(detector)->NumHotwords();
  }

  int SnowboyDetectSampleRate(SnowboyDetect* detector) {
    assert(detector != NULL);
    return reinterpret_cast<snowboy::SnowboyDetect*>(detector)->SampleRate();
  }

  int SnowboyDetectNumChannels(SnowboyDetect* detector) {
    assert(detector != NULL);
    return reinterpret_cast<snowboy::SnowboyDetect*>(detector)->NumChannels();
  }

  int SnowboyDetectBitsPerSample(SnowboyDetect* detector) {
    assert(detector != NULL);
    return reinterpret_cast<snowboy::SnowboyDetect*>(detector)->BitsPerSample();
  }

  void SnowboyDetectDestructor(SnowboyDetect* detector) {
    assert(detector != NULL);
    delete reinterpret_cast<snowboy::SnowboyDetect*>(detector);
    detector = NULL;
  }
}
