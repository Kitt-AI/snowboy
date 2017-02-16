//
//  SnowboyWrapper.h
//  SnowboyTest
//
//  Created by Bi, Sheng on 2/14/17.
//  Copyright © 2017 Bi, Sheng. All rights reserved.
//

#ifndef SnowboyWrapper_h
#define SnowboyWrapper_h

#import <Foundation/Foundation.h>

// This is a wrapper Objective-C++ class around the C++ class snowboy-detect.h
//
// "You cannot import C++ code directly into Swift. Instead, create an Objective-C or C wrapper for C++ code."
// See: https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/index.html#//apple_ref/doc/uid/TP40014216-CH2-ID0
@interface SnowboyWrapper : NSObject

-(id)initWithResources:(NSString*)resourceFileName modelStr:(NSString*)modelStr;
-(int)runDetection:(NSString*)data;
-(int)runDetection:(NSArray*)data length:(int)length;
-(void)setSensitivity:(NSString*)sensitivity;
-(bool)reset;
-(void)setAudioGain:(float)audioGain;
-(int)sampleRate;
-(int)numChannels;
-(int)bitsPerSample;

@end


#endif /* SnowboyWrapper_h */
