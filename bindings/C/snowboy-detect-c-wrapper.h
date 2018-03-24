// snowboy-detect-c-wrapper.h

// Copyright 2017  KITT.AI (author: Guoguo Chen)

#ifndef SNOWBOY_DETECT_C_WRAPPER_H_
#define SNOWBOY_DETECT_C_WRAPPER_H_

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

  typedef struct SnowboyDetect SnowboyDetect;

  SnowboyDetect* SnowboyDetectConstructor(const char* const resource_filename,
                                          const char* const model_str);

  bool SnowboyDetectReset(SnowboyDetect* detector);

  int SnowboyDetectRunDetection(SnowboyDetect* detector,
                                const int16_t* const data,
                                const int array_length, bool is_end);

  void SnowboyDetectSetSensitivity(SnowboyDetect* detector,
                                   const char* const sensitivity_str);

  void SnowboyDetectSetAudioGain(SnowboyDetect* detector,
                                 const float audio_gain);

  void SnowboyDetectUpdateModel(SnowboyDetect* detector);

  void SnowboyDetectApplyFrontend(SnowboyDetect* detector,
                                  const bool apply_frontend);

  int SnowboyDetectNumHotwords(SnowboyDetect* detector);

  int SnowboyDetectSampleRate(SnowboyDetect* detector);

  int SnowboyDetectNumChannels(SnowboyDetect* detector);

  int SnowboyDetectBitsPerSample(SnowboyDetect* detector);

  void SnowboyDetectDestructor(SnowboyDetect* detector);

#ifdef __cplusplus
}
#endif

#endif  // SNOWBOY_DETECT_C_WRAPPER_H_
