//
//  AlphabetViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/30/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "AlphabetViewController.h"

@interface AlphabetViewController () {
    
    IBOutlet UIButton* recordButton;
    IBOutlet UIButton* playButton;
    IBOutlet UIButton* backButton;
    IBOutlet UILabel* durationLabel;
    
    AVAudioRecorder* recorder;
    AVAudioPlayer *player;
}

- (IBAction)recordButtonTouched:(id)sender;
- (IBAction)playButtonTouched:(id)sender;
- (IBAction)backButtonTouched:(id)sender;

@end

@implementation AlphabetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"recorderAudio.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    playButton.hidden = YES;
    //recorder = [AudioManager sharedInstance].recorder;
    //recorder.delegate = self;

}

- (IBAction)recordButtonTouched:(id)sender {
    
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        playButton.hidden = YES;
        
        durationLabel.text = @"Recording...";
        
    } else {
        
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [recordButton setTitle:@"Record" forState:UIControlStateNormal];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        
        durationLabel.text = [NSString stringWithFormat:@"Recorded %.02f seconds",player.duration];
    }
    
    
    [playButton setEnabled:NO];
    
}

- (IBAction)playButtonTouched:(id)sender {
    if (!recorder.recording){

        if (player.playing) {
            [player stop];
            [playButton setTitle:@"Play" forState:UIControlStateNormal];
        }
        else {


            [player play];
            [playButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    
    
    }

}

- (IBAction)backButtonTouched:(id)sender {
    [recorder stop];
    [player stop];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [playButton setEnabled:YES];
    
    
    playButton.hidden = NO;
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
