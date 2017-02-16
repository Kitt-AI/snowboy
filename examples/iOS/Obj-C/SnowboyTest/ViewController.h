//
//  ViewController.h
//  SnowboyTest
//
//  Created by Patrick Quinn on 16/02/2017.
//  Copyright © 2017 Kitt.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <EZAudio/EZAudio.h>


#import "snowboy-detect.h"

@interface ViewController : UIViewController <EZMicrophoneDelegate> {
    snowboy::SnowboyDetect* _snowboyDetect;
    int detection_countdown;
}

@property (strong, nonatomic) IBOutlet UILabel *detected;

@property (nonatomic, strong) EZMicrophone *microphone;



@end

