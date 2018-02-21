#include "portaudio.h"
#include <iostream>
#include <chrono>
#include "snowboy-detect.h"


// mac: g++ -I/usr/local/include -lportaudio -lm -ldl -framework Accelerate -std=c++11  libsnowboy-detect.a demo.cpp -o demo
// http://www.portaudio.com/docs/v19-doxydocs/tutorial_start.html
// http://www.portaudio.com/docs/v19-doxydocs/tutorial_start.html

#define resource_filename "resources/common.res"  //common file path
#define model_filename "resources/snowboy.umdl"		//model name
#define sensitivity_str "0.5"

struct userdata{
	short * buffer;
	int writeindex;
	int chunkksizebytes;
};


static int PaRecordCallback(const void *inputBuffer, void *outputBuffer, unsigned long framesPerBuffer, const PaStreamCallbackTimeInfo* timeInfo,
	PaStreamCallbackFlags statusFlags, void * duserdata) {
	userdata * dstruct = (userdata *) duserdata;
	short * buffer_aux = dstruct->buffer;
	memcpy(&buffer_aux[dstruct->writeindex*framesPerBuffer], inputBuffer, dstruct->chunkksizebytes); //buffer is of samples
	dstruct->writeindex++;
	return paContinue;
}



int main(int argc, char * argv[]) {
	std::string usage = "C++ demo that shows how to use snowboy. In this examle\n"
	"User can acquire audio either from a file either fom the microphone using PortAudio.\n"
	"Atention reading from a file: this software is for simulation/test only,"
	"You need to take precautions when loading a file into the memory.\n"
	"To run the example:\n\n./demo [time to record] [filename.raw]\n\n" 
	"If you just want to use a file, you can use:\n\n./demo - file.raw\n\n"
	"IMPORTANT NOTE: Raw file must be 16kHz sample, mono and 16bit";
	


	//default
	int recordtime; // seconds
	char * filename;
	
	if(argc == 1){
		std::cout << usage << std::endl;
    exit(1);
	}

	if(argc > 1)
		recordtime = atoi(argv[1]);

  if(argc > 2)
		filename = argv[2]; //input: file. else, input: mic
	
	double chunk_duration = 0.1; //1600 frames per buffer
	int channels = 1;
	int sample_rate = 16000;
	short * data_buffer = NULL;
	int fsize = 0;

	if(filename != NULL){
		FILE * f = fopen(filename,"rb");
		if( f == NULL )  {
			perror ("Error opening file");
			return(-1);
		}
		
		// File size
		fseek(f,0,SEEK_END);
		fsize = ftell(f);
		rewind(f);
		
		// Consume all the audio to the buffer
		data_buffer = (short *)malloc(fsize);
 		int aa = fread(&data_buffer[0], 1 ,fsize, f);
 		printf("Read bytes: %d\n",aa);
		fclose(f);
		

	} else {
		
		unsigned long Frames_Per_Buffer = (unsigned long) sample_rate * chunk_duration; //2*1600
		int chunkksizebytes = Frames_Per_Buffer * sizeof(short) * channels;
		fsize = recordtime/chunk_duration*chunkksizebytes;
		data_buffer = (short *)malloc(fsize);

		userdata * dstruct = new userdata();
		dstruct->buffer = data_buffer;
		dstruct->chunkksizebytes = chunkksizebytes;
		dstruct->writeindex = 0;

		PaStreamParameters inputParameters;
		PaStream * stream;
		PaError err = paNoError;

		err = Pa_Initialize(); // Initializing PortAudio API
		if (err != paNoError) {
			perror("Error initializing portaudio");
			exit(-1);
		}

		inputParameters.device = Pa_GetDefaultInputDevice(); // default input device 
		inputParameters.channelCount = channels;
		inputParameters.sampleFormat = paInt16;
		inputParameters.suggestedLatency = Pa_GetDeviceInfo(inputParameters.device)->defaultLowInputLatency;
		inputParameters.hostApiSpecificStreamInfo = NULL;

		err = Pa_OpenStream(&stream, &inputParameters, NULL, sample_rate, Frames_Per_Buffer, paClipOff, PaRecordCallback, dstruct); // initializing stream
		if (err != paNoError) {
			perror("Unable to initialize stream");
			exit(-1);
		}


		err = Pa_StartStream(stream);
		if (err != paNoError) {
			perror((char *)"Unable to start stream\n");
			exit(-1);
		}
		printf("Portaudio initialized\n");

		int timer = 0;
		while (Pa_IsStreamActive(stream) == 1 && timer < recordtime) {
			printf(".\n");
			Pa_Sleep(1010);
			timer++;
		}

		Pa_Terminate();

	}

	
  // Initializes Snowboy detector.
  snowboy::SnowboyDetect detector(resource_filename, model_filename);
  detector.SetSensitivity(sensitivity_str);
  

  
	int result = detector.RunDetection(&data_buffer[0], fsize./sizeof(short));
  printf(">>>>> Result: %d <<<<<\nLegend: -2: noise | -1: error | 0: silence | 1: hotword\n",result);
  auto end = std::chrono::steady_clock::now();
	


	// // Test the computational time of performe the classification
 	// start = std::chrono::steady_clock::now();
 	// result = detector.RunDetection(&data_buffer[0], 64000);
 	// end = std::chrono::steady_clock::now();
	// std::cout << "duration 2: "  << std::chrono::duration_cast<std::chrono::microseconds>(end - start).count()  << std::endl;

  return 0;
}
