// bindings/Ruby/ext/capture/port-audio/port-audio-capture.c

// Copyright 2017  KITT.AI (author: Guoguo Chen, PpiBbuRr)

#include <assert.h>
#include <pa_ringbuffer.h>
#include <pa_util.h>
#include <portaudio.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct {
	// Pointer to the ring buffer memory.
	char* ringbuffer;
	// Ring buffer wrapper used in PortAudio.
	PaUtilRingBuffer pa_ringbuffer;
	// Pointer to PortAudio stream.
	PaStream* pa_stream;
	// Number of lost samples at each LoadAudioData() due to ring buffer overflow.
	int num_lost_samples;
	// Wait for this number of samples in each LoadAudioData() call.
	int min_read_samples;
	// Pointer to the audio data.
	int16_t* audio_data;
} rb_snowboy_port_audio_capture_t;

int rb_snowboy_port_audio_capture_callback(const void* input,
                      void* output,
                      unsigned long frame_count,
                      const PaStreamCallbackTimeInfo* time_info,
                      PaStreamCallbackFlags status_flags,
                      void* user_data) {
						  
  rb_snowboy_port_audio_capture_t* capture = (rb_snowboy_port_audio_capture_t*) user_data;
  ring_buffer_size_t num_written_samples = PaUtil_WriteRingBuffer(&capture->pa_ringbuffer, input, frame_count);
  capture->num_lost_samples += frame_count - num_written_samples;
  return paContinue;
}

void rb_snowboy_port_audio_capture_start_audio_capturing(rb_snowboy_port_audio_capture_t* capture, int sample_rate,
                         int num_channels, int bits_per_sample) {
  capture->audio_data = NULL;
  capture->num_lost_samples = 0;
  capture->min_read_samples = sample_rate * 0.1;

  // Allocates ring buffer memory.
  int ringbuffer_size = 16384;
  capture->ringbuffer = (char*)(
      PaUtil_AllocateMemory(bits_per_sample / 8 * ringbuffer_size));
  if (capture->ringbuffer == NULL) {
    fprintf(stderr, "Fail to allocate memory for ring buffer.\n");
    exit(1);
  }

  // Initializes PortAudio ring buffer.
  ring_buffer_size_t rb_init_ans =
      PaUtil_InitializeRingBuffer(&capture->pa_ringbuffer, bits_per_sample / 8,
                                  ringbuffer_size, capture->ringbuffer);
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
        &capture->pa_stream, num_channels, 0, paUInt8, sample_rate,
        paFramesPerBufferUnspecified, rb_snowboy_port_audio_capture_callback, capture);
  } else if (bits_per_sample == 16) {
    pa_open_ans = Pa_OpenDefaultStream(
        &capture->pa_stream, num_channels, 0, paInt16, sample_rate,
        paFramesPerBufferUnspecified, rb_snowboy_port_audio_capture_callback, capture);
  } else if (bits_per_sample == 32) {
    pa_open_ans = Pa_OpenDefaultStream(
        &capture->pa_stream, num_channels, 0, paInt32, sample_rate,
        paFramesPerBufferUnspecified, rb_snowboy_port_audio_capture_callback, capture);
  } else {
    fprintf(stderr, "Unsupported BitsPerSample: %d.\n", bits_per_sample);
    exit(1);
  }
  if (pa_open_ans != paNoError) {
    fprintf(stderr, "Fail to open PortAudio stream, error message is %s.\n",
           Pa_GetErrorText(pa_open_ans));
    exit(1);
  }

  PaError pa_stream_start_ans = Pa_StartStream(capture->pa_stream);
  if (pa_stream_start_ans != paNoError) {
    fprintf(stderr, "Fail to start PortAudio stream, error message is %s.\n",
           Pa_GetErrorText(pa_stream_start_ans));
    exit(1);
  }
}

void rb_snowboy_port_audio_capture_stop_audio_capturing(rb_snowboy_port_audio_capture_t* capture) {
  if (capture->audio_data != NULL) {
    free(capture->audio_data);
    capture->audio_data = NULL;
  }
  Pa_StopStream(capture->pa_stream);
  Pa_CloseStream(capture->pa_stream);
  Pa_Terminate();
  PaUtil_FreeMemory(capture->ringbuffer);
}

int rb_snowboy_port_audio_capture_load_audio_data(rb_snowboy_port_audio_capture_t* capture) {
  if (capture->audio_data != NULL) {
    free(capture->audio_data);
    capture->audio_data = NULL;
  }

  // Checks ring buffer overflow.
  if (capture->num_lost_samples > 0) {
    fprintf(stderr, "Lost %d samples due to ring buffer overflow.\n",
            capture->num_lost_samples);
    capture->num_lost_samples = 0;
  }

  ring_buffer_size_t num_available_samples = 0;
  while (true) {
    num_available_samples =
        PaUtil_GetRingBufferReadAvailable(&capture->pa_ringbuffer);
    if (num_available_samples >= capture->min_read_samples) {
      break;
    }
    Pa_Sleep(5);
  }

  // Reads data.
  num_available_samples = PaUtil_GetRingBufferReadAvailable(&capture->pa_ringbuffer);
  capture->audio_data = malloc(num_available_samples * sizeof(int16_t));
  ring_buffer_size_t num_read_samples = PaUtil_ReadRingBuffer(
      &capture->pa_ringbuffer, capture->audio_data, num_available_samples);
  if (num_read_samples != num_available_samples) {
    fprintf(stderr, "%d samples were available, but only %d samples were read"
            ".\n", num_available_samples, num_read_samples);
  }
  return num_read_samples;
}

rb_snowboy_port_audio_capture_t* rb_snowboy_port_audio_capture_new() {
  rb_snowboy_port_audio_capture_t* capture = malloc(sizeof(rb_snowboy_port_audio_capture_t));
	
  memset(capture, 0, sizeof(rb_snowboy_port_audio_capture_t));
	
  return capture;
}

int16_t* rb_snowboy_port_audio_capture_get_audio_data(rb_snowboy_port_audio_capture_t* capture) {
  return capture->audio_data;
}
