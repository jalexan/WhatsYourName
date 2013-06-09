//
//  GameController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/27/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "GameController.h"

@interface GameController () {
    
}

@end

@implementation GameController
@synthesize audioManager;
@synthesize soundButton;
@synthesize screenBounds;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    screenBounds = CGSizeMake(480,320);
    
    self.audioManager = [AudioManager sharedInstance];
    
    [soundButton setImage:[UIImage imageNamed:@"Resource/sound_on.png"] forState:UIControlStateNormal];
    [soundButton setImage:[UIImage imageNamed:@"Resource/sound_off.png"] forState:UIControlStateSelected];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pauseMusic"] != 0) {
        soundButton.selected = YES;
    }
	else {
        soundButton.selected = NO;
    }

    
}

- (void)viewDidAppear:(BOOL)animated {
    if (DEBUG_DRAW_BORDERS) {
        [self.view drawBorderOnSubviews];
    }
    
    if (DEBUG_DRAW_SIZES) {
        [self.view drawSizeLabelOnSubviews];
    }
}


- (NSTimeInterval)getDurationAndPlaySpeakerDialogAudioWithKey:(NSString*)key prefix:(NSString*)prefix  suffix:(NSString*)suffix {
    NSString* path = [NSString stringWithFormat:@"Speakers/%@/Audio/%@%@.mp3",prefix,key,suffix];
    [self.audioManager prepareAudioWithPath:path key:@"talking"];
    NSTimeInterval t = [self.audioManager durationOfAudio:@"talking"];

    if (SKIP_DIALOG) {
        t = 0;
    }

    [self.audioManager playAudio:@"talking" volume:.1];
    return t;
}

- (IBAction)soundButtonTouched:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (audioManager.backgroundPlayer.isPlaying) {
        [audioManager.backgroundPlayer pause];
        soundButton.selected = YES;
        [userDefaults setBool:YES forKey:@"pauseMusic"];
    }
    else {
        audioManager.backgroundPlayer.volume = BG_MUSIC_VOLUME;
        [audioManager.backgroundPlayer play];
        soundButton.selected = NO;
        [userDefaults setBool:NO forKey:@"pauseMusic"];
    }
}

- (void)applicationWillResignActive{
    [audioManager pauseAudio:@"bg"];
}

- (void)applicationDidBecomeActive{
    
    [audioManager initializeAudio];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
