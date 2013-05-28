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
    
    self.audioManager = [AudioManager sharedInstance];
    
    [soundButton setImage:[UIImage imageNamed:@"Resource/sound_on"] forState:UIControlStateNormal];
    [soundButton setImage:[UIImage imageNamed:@"Resource/sound_off"] forState:UIControlStateSelected];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pauseMusic"] != 0) {
        soundButton.selected = YES;
    }
	else {
        soundButton.selected = NO;
    }
    
    
    
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
