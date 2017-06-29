//
//  SnowboyWrapper.m
//  SnowboyTest
//
//  Created by Bi, Sheng on 2/14/17.
//  Copyright © 2017 Bi, Sheng. All rights reserved.
//

#import "SnowboyWrapper.h"
#import "snowboy-detect.h"

@interface SnowboyWrapper()
{
    snowboy::SnowboyDetect* snowboy;
}
@end

@implementation SnowboyWrapper

-(id)initWithResources:(NSString*)resourceFileName modelStr:(NSString*)modelStr
{
    std::string resource = [resourceFileName cStringUsingEncoding:[NSString defaultCStringEncoding]];
    std::string model = [modelStr cStringUsingEncoding:[NSString defaultCStringEncoding]];
    snowboy = new snowboy::SnowboyDetect(resource, model);
    return self;
}

-(void)setSensitivity:(NSString*)sensitivity
{
    snowboy->SetSensitivity([sensitivity cStringUsingEncoding:[NSString defaultCStringEncoding]]);
}

-(int)runDetection:(NSString*)data
{
    return snowboy->RunDetection([data cStringUsingEncoding:[NSString defaultCStringEncoding]]);
}

-(int)runDetection:(NSArray*)data length:(int)length
{
    long count = [data count];
    float* dataArray = (float*) malloc(sizeof(float*) * count);
    for (int i = 0; i < count; ++i) {
        dataArray[i] = [[data objectAtIndex:i] floatValue];
    }
    
    int detected = snowboy->RunDetection(dataArray, length);
    free(dataArray);
    return detected;
}

-(bool)reset
{
    return snowboy->Reset();
}

-(void)setAudioGain:(float)audioGain
{
    return snowboy->SetAudioGain(audioGain);
}

-(int)sampleRate
{
    return snowboy->SampleRate();
}

-(int)numChannels
{
    return snowboy->NumChannels();
}

-(int)bitsPerSample
{
    return snowboy->BitsPerSample();
}

@end
