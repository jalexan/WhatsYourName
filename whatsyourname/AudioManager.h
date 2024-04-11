//
//  AudioManager.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/27/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#define BG_MUSIC_VOLUME 0.20

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//@interface AudioManager : NSObject <AVAudioSessionDelegate> {

@interface AudioManager : NSObject {

}
+ (AudioManager*)sharedInstance;

@property (nonatomic,readonly) AVAudioPlayer* backgroundPlayer;

- (void)initializeAudio;
- (void)setAudioSessionCategory:(NSString*)theCategory;
- (AVAudioPlayer*)prepareAudioWithPath:(NSString*)audioPath;
- (AVAudioPlayer*)prepareAudioWithPath:(NSString*)audioPath key:(NSString*)key;
- (void)playAudio:(NSString*)audioName volume:(float)volume;
- (void)stopAudio:(NSString*)audioName;
- (void)pauseAudio:(NSString*)audioName;
- (NSTimeInterval)durationOfAudio:(NSString*)audioName;
- (void)prepareBackgroundAudioWithPath:(NSString*)audioPath volume:(float)volume;
- (BOOL)hasErrorAudio;
- (void)loadErrorAudioWithPrefix:(NSString*)prefix key:(NSString*)key;
- (NSTimeInterval)playErrorAudio;
@end
