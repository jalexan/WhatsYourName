//
//  AudioManager.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/27/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "AudioManager.h"
#import "Singleton.h"

@interface AudioManager () {
    //Audio
    NSMutableDictionary* audioNameToPlayer;
    AVAudioPlayer* backgroundPlayer;
    BOOL otherAudioIsPlaying;
}
@end


@implementation AudioManager
SYNTHESIZE_SINGLETON_FOR_CLASS(AudioManager)

@synthesize backgroundPlayer;

- (id)init {
	if ((self = [super init])) {
        
        [self initializeAudio];
        [self playBackgroundAudioWithPath:@"Resource/bg.mp3" volume:BG_MUSIC_VOLUME];
        
	}
	return self;
}


#pragma mark Audio
- (void)initializeAudio{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory: AVAudioSessionCategoryAmbient error: nil];
    [session setDelegate:self];
    
    UInt32 otherAudioIsPlayingVal;
    UInt32 propertySize = sizeof (otherAudioIsPlayingVal);
    
    AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying,
                             &propertySize,
                             &otherAudioIsPlayingVal
                             );
    otherAudioIsPlaying = (BOOL)otherAudioIsPlayingVal;
    if (otherAudioIsPlaying){
        [backgroundPlayer pause];
    } else {
        backgroundPlayer.volume = BG_MUSIC_VOLUME;
        [backgroundPlayer play];
    }
}

- (AVAudioPlayer*)prepareAudioWithPath:(NSString*)audioPath {
    return [self prepareAudioWithPath:audioPath key:audioPath];
}

- (AVAudioPlayer*)prepareAudioWithPath:(NSString*)audioPath key:(NSString*)key {
    
    
    if (audioNameToPlayer == nil){
        audioNameToPlayer = [NSMutableDictionary new];
    }
    
    NSError* error;
    
    AVAudioPlayer* player = nil;
    @try {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",audioPath] ofType:nil]];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [player prepareToPlay];
    }
    @catch(NSException* e) {
        NSLog(@"error in prepareAudioWithPath: audioPath: %@ Error: %@",audioPath,e.description);
    }
    
    [audioNameToPlayer setValue:player forKey:key];
    return player;
    
    
}

- (void)playAudio:(NSString*)audioName volume:(float)volume {
    [self playAudio:audioName volume:volume pan:0.0];
}

- (void)stopAudio:(NSString*)audioName {
    AVAudioPlayer* player = [audioNameToPlayer valueForKey:audioName];
    [player stop];
}

- (void)pauseAudio:(NSString*)audioName {
    AVAudioPlayer* player = [audioNameToPlayer valueForKey:audioName];
    [player pause];
}

- (void)playAudio:(NSString*)audioName volume:(float)volume pan:(float)pan{
    //if (alwaysPlayAudioEffects || !otherAudioIsPlaying){
    AVAudioPlayer* player = [audioNameToPlayer valueForKey:audioName];
    
    NSArray* params = [NSArray arrayWithObjects:player, [NSNumber numberWithFloat:volume], [NSNumber numberWithFloat:pan], nil];
    
    if ([params count]>0) {
        [self performSelectorInBackground:@selector(playAudioInBackground:) withObject:params];
    }
    //}
}

- (void)playAudioInBackground:(NSArray*)params{
    
    if ([params count]>0) {
        AVAudioPlayer* player = [params objectAtIndex:0];
        
        NSNumber* volume = [params objectAtIndex:1];
        NSNumber* pan = [params objectAtIndex:2];
        
        [player setCurrentTime:0];
        [player setVolume: [volume floatValue]];
        [player setPan: [pan floatValue]];
        
        [player play];
    }
    
}
- (void)playBackgroundAudioWithPath:(NSString*)audioPath volume:(float)volume {
    if (backgroundPlayer != nil){
        [backgroundPlayer stop];
    }
    backgroundPlayer = [self prepareAudioWithPath:audioPath];
    [backgroundPlayer setNumberOfLoops:-1];
    
    if (!otherAudioIsPlaying){
        backgroundPlayer.volume = BG_MUSIC_VOLUME;
        [backgroundPlayer play];
    }
}
- (void)beginInterruption{
    [backgroundPlayer pause];
}
- (void)endInterruption{
    backgroundPlayer.volume = BG_MUSIC_VOLUME;
    [backgroundPlayer play];
}


@end
