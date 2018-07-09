//
//  ViewController.m
//  SnowboyTest
//
//  Created by Patrick Quinn on 16/02/2017.
//  Copyright © 2017 Kitt.ai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPermissions];
    [self initSnowboy];
    [self initMic];
}

- (void) initPermissions {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:nil];
}

- (void)initSnowboy {
    _snowboyDetect = NULL;
    _snowboyDetect = new snowboy::SnowboyDetect(std::string([[[NSBundle mainBundle]pathForResource:@"common" ofType:@"res"] UTF8String]),
                                                std::string([[[NSBundle mainBundle]pathForResource:@"alexa" ofType:@"umdl"] UTF8String]));
    _snowboyDetect->SetSensitivity("0.5");
    _snowboyDetect->SetAudioGain(1.0);
    _snowboyDetect->ApplyFrontend(false);
}

- (void) initMic {
    AudioStreamBasicDescription audioStreamBasicDescription = [EZAudioUtilities monoFloatFormatWithSampleRate:16000];
    audioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM;
    audioStreamBasicDescription.mSampleRate = 16000;
    audioStreamBasicDescription.mFramesPerPacket = 1;
    audioStreamBasicDescription.mBytesPerPacket = 2;
    audioStreamBasicDescription.mBytesPerFrame = 2;
    audioStreamBasicDescription.mChannelsPerFrame = 1;
    audioStreamBasicDescription.mBitsPerChannel = 16;
    audioStreamBasicDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    audioStreamBasicDescription.mReserved = 0;
    
    NSArray *inputs = [EZAudioDevice inputDevices];
    [self.microphone setDevice:[inputs lastObject]];
    self.microphone = [EZMicrophone microphoneWithDelegate:self withAudioStreamBasicDescription:audioStreamBasicDescription];
    [self.microphone startFetchingAudio];
}

-(void) microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    dispatch_async(dispatch_get_main_queue(),^{
        int result = _snowboyDetect->RunDetection(buffer[0], bufferSize);
        if (result == 1) {
            self.detected.text = @"Hotword Detected";
            detection_countdown = 30;
        } else {
            if (detection_countdown == 0){
                self.detected.text = @"No Hotword Detected";
            } else {
                detection_countdown--;
            }
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self initSnowboy];
}


@end
