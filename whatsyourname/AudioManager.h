//
//  AudioManager.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/27/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#define BG_MUSIC_VOLUME 0.05

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager : NSObject <AVAudioSessionDelegate> {
    
}
+ (AudioManager*)sharedInstance;

@property (nonatomic,readonly) AVAudioPlayer* backgroundPlayer;

- (void)initializeAudio;
- (AVAudioPlayer*)prepareAudio:(NSString*)audioName;
- (void)playAudio:(NSString*)audioName volume:(float)volume;
- (void)stopAudio:(NSString*)audioName;
- (void)pauseAudio:(NSString*)audioName;
- (void)playBackgroundAudio:(NSString*)audioName volume:(float)volume;


@end
