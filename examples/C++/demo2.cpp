#include "portaudio.h"
#include <iostream>
#include <chrono>
#include "../../include/snowboy-detect.h"

#define resource_filename "resources/common.res" 
#define model_filename "resources/snowboy.umdl" 
#define sensitivity_str "0.5"

int main(int argc, char * argv[]) {
 std::string usage = 
 "C++ demo that shows how to use snowboy. In this examle\n"
 "User can read the audio data from a file.\n"
 "Atention reading from a file: this software is for simulation/test only,"
 "You need to take precautions when loading a file into the memory.\n"
 "To run the example:\n\n./demo [time to record] [filename.raw]\n\n" 
 "If you just want to use a file, you can use:\n\n./demo file.raw\n\n"
 "IMPORTANT NOTE: Raw file must be 16kHz sample, mono and 16bit";
 
 //default
 char * filename;
 int fsize;
 short * data_buffer = NULL;
 bool isRaw;
 if(argc > 2 || argc < 1){
  std::cout << usage << std::endl;
    exit(1);
 }

 if(argc > 1)
  filename = argv[1]; //input: file. else, input: mic

	std::string str = filename;
	std::string type = ".wav";
	if (str.find(type) != std::string::npos) {
    std::cout << "found!" << '\n';
	}



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
  
	} 
 
  // Initializes Snowboy detector.
  snowboy::SnowboyDetect detector(resource_filename, model_filename);
  detector.SetSensitivity(sensitivity_str);
  
  int result = detector.RunDetection(&data_buffer[0], fsize/sizeof(short));
  printf(">>>>> Result: %d <<<<<\n",result);
  printf("Legend: -2: noise | -1: error | 0: silence | 1: hotword\n");
  auto end = std::chrono::steady_clock::now();
 
  return 0;
}
