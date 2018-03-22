// example/Ruby/port_audio_detect.c

// Copyright 2017  KITT.AI (author: Guoguo Chen, PpiBbuRr)

#include <assert.h>
#include <pa_ringbuffer.h>
#include <pa_util.h>
#include <portaudio.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#include "snowboy-detect-c-wrapper.h"

// Pointer to the ring buffer memory.
char* g_ringbuffer;
// Ring buffer wrapper used in PortAudio.
PaUtilRingBuffer g_pa_ringbuffer;
// Pointer to PortAudio stream.
PaStream* g_pa_stream;
// Number of lost samples at each LoadAudioData() due to ring buffer overflow.
int g_num_lost_samples;
// Wait for this number of samples in each LoadAudioData() call.
int g_min_read_samples;
// Pointer to the audio data.
int16_t* g_data;

int PortAudioCallback(const void* input,
                      void* output,
                      unsigned long frame_count,
                      const PaStreamCallbackTimeInfo* time_info,
                      PaStreamCallbackFlags status_flags,
                      void* user_data) {
  ring_buffer_size_t num_written_samples =
      PaUtil_WriteRingBuffer(&g_pa_ringbuffer, input, frame_count);
  g_num_lost_samples += frame_count - num_written_samples;
  return paContinue;
}

void StartAudioCapturing(int sample_rate,
                         int num_channels, int bits_per_sample) {
  g_data = NULL;
  g_num_lost_samples = 0;
  g_min_read_samples = sample_rate * 0.1;

  // Allocates ring buffer memory.
  int ringbuffer_size = 16384;
  g_ringbuffer = (char*)(
      PaUtil_AllocateMemory(bits_per_sample / 8 * ringbuffer_size));
  if (g_ringbuffer == NULL) {
    fprintf(stderr, "Fail to allocate memory for ring buffer.\n");
    exit(1);
  }

  // Initializes PortAudio ring buffer.
  ring_buffer_size_t rb_init_ans =
      PaUtil_InitializeRingBuffer(&g_pa_ringbuffer, bits_per_sample / 8,
                                  ringbuffer_size, g_ringbuffer);
  if (rb_init_ans == -1) {
    fprintf(stderr, "Ring buffer size is not power of 2.\n");
    exit(1);
  }

  // Initializes PortAudio.
  PaError pa_init_ans = Pa_Initialize();
  if (pa_init_ans != paNoError) {
    fprintf(stderr, "Fail to initialize PortAudio, error message is %s.\n",
           Pa_GetErrorText(pa_init_ans));
    exit(1);
  }

  PaError pa_open_ans;
  if (bits_per_sample == 8) {
    pa_open_ans = Pa_OpenDefaultStream(
        &g_pa_stream, num_channels, 0, paUInt8, sample_rate,
        paFramesPerBufferUnspecified, PortAudioCallback, NULL);
  } else if (bits_per_sample == 16) {
    pa_open_ans = Pa_OpenDefaultStream(
        &g_pa_stream, num_channels, 0, paInt16, sample_rate,
        paFramesPerBufferUnspecified, PortAudioCallback, NULL);
  } else if (bits_per_sample == 32) {
    pa_open_ans = Pa_OpenDefaultStream(
        &g_pa_stream, num_channels, 0, paInt32, sample_rate,
        paFramesPerBufferUnspecified, PortAudioCallback, NULL);
  } else {
    fprintf(stderr, "Unsupported BitsPerSample: %d.\n", bits_per_sample);
    exit(1);
  }
  if (pa_open_ans != paNoError) {
    fprintf(stderr, "Fail to open PortAudio stream, error message is %s.\n",
           Pa_GetErrorText(pa_open_ans));
    exit(1);
  }

  PaError pa_stream_start_ans = Pa_StartStream(g_pa_stream);
  if (pa_stream_start_ans != paNoError) {
    fprintf(stderr, "Fail to start PortAudio stream, error message is %s.\n",
           Pa_GetErrorText(pa_stream_start_ans));
    exit(1);
  }
}

void StopAudioCapturing() {
  if (g_data != NULL) {
    free(g_data);
    g_data = NULL;
  }
  Pa_StopStream(g_pa_stream);
  Pa_CloseStream(g_pa_stream);
  Pa_Terminate();
  PaUtil_FreeMemory(g_ringbuffer);
}

int LoadAudioData() {
  if (g_data != NULL) {
    free(g_data);
    g_data = NULL;
  }

  // Checks ring buffer overflow.
  if (g_num_lost_samples > 0) {
    fprintf(stderr, "Lost %d samples due to ring buffer overflow.\n",
            g_num_lost_samples);
    g_num_lost_samples = 0;
  }

  ring_buffer_size_t num_available_samples = 0;
  while (true) {
    num_available_samples =
        PaUtil_GetRingBufferReadAvailable(&g_pa_ringbuffer);
    if (num_available_samples >= g_min_read_samples) {
      break;
    }
    Pa_Sleep(5);
  }

  // Reads data.
  num_available_samples = PaUtil_GetRingBufferReadAvailable(&g_pa_ringbuffer);
  g_data = malloc(num_available_samples * sizeof(int16_t));
  ring_buffer_size_t num_read_samples = PaUtil_ReadRingBuffer(
      &g_pa_ringbuffer, g_data, num_available_samples);
  if (num_read_samples != num_available_samples) {
    fprintf(stderr, "%d samples were available, but only %d samples were read"
            ".\n", num_available_samples, num_read_samples);
  }
  return num_read_samples;
}


