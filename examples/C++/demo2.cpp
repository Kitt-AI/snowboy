#include "portaudio.h"
#include <iostream>
#include <chrono>
#include "../../include/snowboy-detect.h"

#define resource_filename "resources/common.res" 
#define model_filename "resources/snowboy.umdl" 
#define sensitivity_str "0.5"

struct wavHeader { //44 byte HEADER only
  char  RIFF[4];
  int RIFFsize; 
  char  fmt[8]; 
  int fmtSize;  
  short fmtTag; 
  short nchan;  
  int fs;   
  int avgBps;
  short nBlockAlign;
  short  bps;   
  char  data[4];
  int datasize; 
};


void readWavHeader(wavHeader *wavhdr, FILE *fi){
//=====================================================
// Reads the WAV file header considering the follow restrictions:
// - format tag needs to be 1=PCM (no encoding)
// - <data chunk> shoud be imidiately before the databytes 
// (it should not contain chunks after 'data')
// Returns a pointer pointing to the begining of the data

  char *tag = (char *)wavhdr;
  fread(wavhdr, 34, 1, fi); //starting tag should be "RIFF"
  if (tag[0] != 'R' || tag[1] != 'I' || tag[2] != 'F' || tag[3] != 'F'){
    fclose(fi);
    perror("NO 'RIFF'.");
  }
  if (wavhdr->fmtTag != 1){
    fclose(fi);
    perror("WAV file has encoded data or it is WAVEFORMATEXTENSIBLE.");
  }
  if (wavhdr->fmtSize == 14){
      wavhdr->bps = 16;
  }
  if (wavhdr->fmtSize >= 16){
      fread(&wavhdr->bps, 2, 1, fi);
  }
  if (wavhdr->fmtSize == 18) {
    short lixo;
    fread(&lixo, 2, 1, fi);
  }

  tag += 36; //aponta para wavhdr->data
  fread(tag, 4, 1, fi); //data chunk deve estar aqui.
  while (tag[0] != 'd' || tag[1] != 'a' || tag[2] != 't' || tag[3] != 'a')
  { //tenta encontrar o data chunk mais à frente (sempre em múltilos de 4)
    fread(tag, 4, 1, fi);
    if (ftell(fi) >= long(wavhdr->RIFFsize)) {
      fclose(fi);
      perror("Bad WAV header !");
    }
  }
  fread(&wavhdr->datasize, 4, 1, fi); //data size
  // Assuming that header ends here. 
  // From here until the end it is audio data
}



int main(int argc, char * argv[]) {
 char * usage = (char *) "C++ demo that shows how to use snowboy. \
 In this examle user can read the audio data from a file.\n \
 Atention reading from a file: this software is for simulation/test only, \
 You need to take precautions when loading a file into the memory.\n \
 To run the example:\n\n./demo2 [filename.raw || filename.wav ]\n\n \
 If you just want to use a file, you can use:\n\n./demo2 file.raw\n\n \
 IMPORTANT NOTE: Raw file must be 16kHz sample, mono and 16bit";
 
 //default
 char * filename;
 int fsize;
 short * data_buffer = NULL;
 bool isRaw;
 FILE * f;
 
 if(argc > 2 or argc < 2){
  printf("%s\n",usage);
  exit(1);
 }

 if(argc > 1){
  filename = argv[1]; //input: file. else, input: mic
 }

 std::string str = filename;
 std::string type = ".wav";

 if (str.find(type) != std::string::npos) {
  isRaw = false;
 }


 if(filename != NULL)
  f = fopen(filename,"rb");
  
  if( f == NULL ){
   perror ("Error opening file");
   return(-1);
  }

  if(!isRaw){
    wavHeader *wavhdr = new wavHeader();
    readWavHeader(wavhdr, f);

    short *data = (short *)malloc(wavhdr->datasize);
     // Consume all the audio to the buffer
    fread(data, wavhdr->datasize, 1, f);
    fclose(f);

  } else {
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
