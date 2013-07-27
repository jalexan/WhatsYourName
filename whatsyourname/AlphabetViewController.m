//
//  AlphabetViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/30/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "AlphabetViewController.h"
#import "Speaker.h"
#import "SpeakerImageView.h"
#import "ArabicLetter.h"
#import "ArabicLetterImageView.h"
#import "Slot.h"
#import "SlotImageView.h"
#import "GameUIButton.h"

@interface AlphabetViewController () {
    
    IBOutlet GameUIButton* recordButton;
    IBOutlet GameUIButton* playButton;
    IBOutlet GameUIButton* backButton;
    IBOutlet UILabel* durationLabel;
    
    AVAudioRecorder* recorder;
    AVAudioPlayer *player;
    
    UIView *view;
    UIView *chalkboard;
//    UILabel *dialogLabel;
    Speaker* currentSpeaker;
    SpeakerImageView* speakerImageView;
}

- (IBAction)recordButtonTouched:(id)sender;
- (IBAction)playButtonTouched:(id)sender;
- (IBAction)backButtonTouched:(id)sender;

@end

@implementation AlphabetViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [super.audioManager prepareAudioWithPath:@"Speakers/Samia/Audio/AlphabetSongArabic.mp3"];
    
    //LEFT OFF HERE - 
    //Add background image
    //view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenBounds.width, self.screenBounds.height)];
    UIImageView* screenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/background_alphabets.png"]];
    screenBackground.frame = CGRectMake(0,0,self.screenBounds.width, self.screenBounds.height);
    [self.view addSubview:screenBackground];

    //Add Chalkboard in UIView section
    chalkboard = [[UIView alloc] initWithFrame:CGRectMake(137, 90, 331, 221)]; //TEMP - until i create the new reduced chalkboard img
    chalkboard.backgroundColor = [UIColor clearColor];
    [self.view addSubview:chalkboard];
    
    //Add dialog view in UIView section
    dialogLabel = [[UILabel alloc] initWithFrame:CGRectMake(134, 13, 335, 68)];
    dialogLabel.backgroundColor = [UIColor clearColor];
    dialogLabel.textAlignment = UITextAlignmentCenter;
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
    dialogLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:dialogLabel];
    
    //Add Miss Samia as Speaker
    currentSpeaker = [[Speaker alloc] initWithName:@"Samia"];
    speakerImageView = [[SpeakerImageView alloc] initWithFrame:CGRectMake(9, 24, 119, 290) speaker:currentSpeaker];
    speakerImageView.contentMode = UIViewContentModeBottomLeft;
    [self.view addSubview:speakerImageView];
    [speakerImageView repeatAnimation:DEFAULT];

    [self startAlphabetPhase];
    
    //Add array of arabic letters all 28  - import ArabicLetter model
    //in Chalkboard UIView section, add each row of 7 letters from right to left, decreasing X coord
    //I will need an instance of Audio Manager here
    
    //JUST FOR NOW - just display 1 arabic letter and do the touch / scale effect
    //add touchesBegan here .. then delegate to the View that the touch happened so that it can then scale
    //then add sound
    //then lookup "outlet collections" to control target/action for the whole set of letters
    
    [self startRecordingPhase];
    [self.view sendSubviewToBack:screenBackground];

    recordButton.hidden = YES;
    playButton.hidden = YES;
}

- (void)startAlphabetPhase {
    
    speakerImageView.hidden = NO;
    
    [self displayDialogTextWithKey:@"ThisIs" animationType:TALK completion:^() {

        [self displayDialogTextWithKey:@"AlphabetSong" animationType:TALK completion:^() {

            [self displayDialogTextWithKey:@"SingAlong" animationType:TALK completion:^() {
            
          //  [self spellArabicNameWithCompletion:^() {
                
             //   [self showSpeakerShuffleAnimationWithCompletion:^() {
                    
               //     [self mixUpLettersWithCompletion: ^() {
                        
                 //       if (!shuffleImageView.animationFound) {
                 //           [self displayDialogTextWithKey:@"Shuffle" animationType:TALK completion:^() {
                                
                  //              [self displayDialogTextWithKey:@"Try" animationType:TALK completion:^() {
                                    
                  //              }];
                  //          }];
                 //       }
                 //       else {
                  //          [self displayDialogTextWithKey:@"Try" animationType:TALK completion:^() {
                                
                  //          }];
                 //       }
                        
                        
                //    }];
                    
             //   }];
                
          //  }];
            
            }];
        }];
    }];
}

-(void)startRecordingPhase {

    //Recording section
    //
    // Set the audio file
    recordButton.hidden = NO;
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"recorderAudio.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    //AVAudioSession *session = [AVAudioSession sharedInstance];
    //[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
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

}

#pragma mark Game Mechanics
- (void)displayDialogTextWithKey:(NSString*)key animationType:(AnimationType)animationType completion:(void(^)())completion {
    
    NSDictionary* dialogDictionary = [currentSpeaker dialogForKey:key];
    if (!dialogDictionary)
        return;
    
    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = nil;
    
    if ([dialogDictionary count]>1) {
        arabicText = [[currentSpeaker dialogForKey:key] objectForKey:@"Arabic"];
    }
    
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:dialogLabel.font.pointSize];
    dialogLabel.text = text;
    
    NSTimeInterval englishDialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:currentSpeaker.name suffix:@"English"];
    NSTimeInterval arabicDialogDuration = [self getDurationDialogAudioWithKey:key prefix:currentSpeaker.name suffix:@"Arabic"];
    NSTimeInterval dialogDuration = englishDialogDuration + arabicDialogDuration;
    
    [speakerImageView animateWithType:animationType repeatingDuration:dialogDuration];

    dispatch_after(DISPATCH_SECONDS_FROM_NOW(englishDialogDuration), dispatch_get_current_queue(), ^{
        
        dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:dialogLabel.font.pointSize];
        dialogLabel.text = arabicText;
        [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:currentSpeaker.name suffix:@"Arabic"];
        
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(arabicDialogDuration), dispatch_get_current_queue(), ^{
            completion();
        });
        
        
    });
    
    
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (IBAction)restartButtonTouched:(id)sender {
    [super restartButtonTouched:sender];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPopViewControllerNotification object:self];
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
