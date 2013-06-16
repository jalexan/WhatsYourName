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
    
    NSMutableArray* errorDialogSoundsArray;
    BOOL playedSequentialErrorAudio;
    int sequentialErrorAudioIndex;
}
@end


@implementation AudioManager
SYNTHESIZE_SINGLETON_FOR_CLASS(AudioManager)

@synthesize backgroundPlayer;

- (id)init {
	if ((self = [super init])) {
        
        [self initializeAudio];
        
        
        [self prepareBackgroundAudioWithPath:@"Resource/bg.mp3" volume:BG_MUSIC_VOLUME];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pauseMusic"] == 0 && !otherAudioIsPlaying) {
            [backgroundPlayer play];
        }

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

- (BOOL)hasErrorAudio {
    return errorDialogSoundsArray.count>0;
}

- (void)loadErrorAudioWithPrefix:(NSString*)prefix key:(NSString*)key {
    playedSequentialErrorAudio = NO;
    sequentialErrorAudioIndex = 0;
    
    errorDialogSoundsArray = [[NSMutableArray alloc] init];
    
    for (int i=1;i<9;i++) {
        
        NSString* path = [NSString stringWithFormat:@"Speakers/%@/Audio/%@Arabic%d.mp3",prefix,key,i];
        
        NSURL *url = nil;

        @try {
            url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:path
                                             ofType:nil]];
        }
        @catch(NSException* e) {
            NSLog(@"error in loadErrorAudioWithPrefix: audioPath: %@ Error: %@",path,e.description);
        }
        
        if (url) {
            [errorDialogSoundsArray addObject:path];
        }
    }
}

- (NSTimeInterval)playErrorAudio {
    
    NSTimeInterval t = 0;
    
    if (playedSequentialErrorAudio) {
        NSUInteger randomErrorAudioIndex = (arc4random() % errorDialogSoundsArray.count);
        
        NSString* path = errorDialogSoundsArray[randomErrorAudioIndex];
        [self prepareAudioWithPath:path key:@"talking"];
        t = [self durationOfAudio:@"talking"];
        [self playAudio:@"talking" volume:0.1];
        
    }
    else {
        
        if (errorDialogSoundsArray.count>0 && sequentialErrorAudioIndex < errorDialogSoundsArray.count) {
            NSString* path = errorDialogSoundsArray[sequentialErrorAudioIndex];
            [self prepareAudioWithPath:path key:@"talking"];
            t = [self durationOfAudio:@"talking"];
            [self playAudio:@"talking" volume:0.1];
            sequentialErrorAudioIndex++;
            
            if (sequentialErrorAudioIndex==errorDialogSoundsArray.count) {
                playedSequentialErrorAudio = YES;
            }

        }
        
    }
    
    return t;
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

- (NSTimeInterval)durationOfAudio:(NSString*)audioName {
    AVAudioPlayer* player = [audioNameToPlayer valueForKey:audioName];
    return player.duration;
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

- (void)prepareBackgroundAudioWithPath:(NSString*)audioPath volume:(float)volume {
    if (backgroundPlayer != nil){
        [backgroundPlayer stop];
    }
    backgroundPlayer = [self prepareAudioWithPath:audioPath];
    [backgroundPlayer setNumberOfLoops:-1];
    backgroundPlayer.volume = BG_MUSIC_VOLUME;

}

- (void)beginInterruption{
    [backgroundPlayer pause];
}
- (void)endInterruption{
    backgroundPlayer.volume = BG_MUSIC_VOLUME;
    [backgroundPlayer play];
}


@end
