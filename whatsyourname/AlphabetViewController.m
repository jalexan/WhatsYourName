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
#import "ArabicLetterAudioImageView.h"
#import "Slot.h"
#import "SlotImageView.h"
#import "GameUIButton.h"

@interface AlphabetViewController () <ArabicLetterAudioImageViewDelegate> {
    
    IBOutlet GameUIButton* recordButton;
    IBOutlet GameUIButton* playButton;
    IBOutlet GameUIButton* bonusLevelButton;
    IBOutlet UILabel* durationLabel;
    
    AVAudioRecorder* recorder;
    AVAudioPlayer *player;
    
    UIView *view;
    UIImageView *chalkboard;
//    UILabel *dialogLabel;
    UILabel *chalkboardLabel;
    UILabel *subtitleLabel;
    NSString *unicodeNameStringForSpelling;
    Speaker* currentSpeaker;
    SpeakerImageView* speakerImageView;
    float songDelay;
    BOOL recordedPlayedOnce;
    //BOOL shouldStopSinging;
    NSMutableArray *letterImageViewArray;
    BOOL chalkboardNeedsReset;
}

- (IBAction)recordButtonTouched:(id)sender;
- (IBAction)playButtonTouched:(id)sender;
- (IBAction)bonusButtonTouched:(id)sender;

@end

@implementation AlphabetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super.audioManager prepareAudioWithPath:@"Speakers/Samia/Audio/AlphabetSongArabic.mp3"];
    
    //Add background image
    //view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenBounds.width, self.screenBounds.height)];
    UIImageView* screenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/background_alphabets.png"]];
    screenBackground.frame = CGRectMake(0,0,self.screenBounds.width, self.screenBounds.height);
    [self.view addSubview:screenBackground];

    //Add Chalkboard in UIView section
    UIImage *cImg = [[UIImage imageNamed:@"Resource/chalkboard.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:5];
    chalkboard = [[UIImageView alloc] initWithImage:cImg]; //TEMP - until i create the new reduced chalkboard img
    chalkboard.frame = CGRectMake(132, 65, 331, 210);
    [self.view addSubview:chalkboard];

    [self resetChalkboard];

    //Add dialog view in UIView section
    dialogLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 448, 48)];
    dialogLabel.backgroundColor = [UIColor clearColor];
    dialogLabel.textAlignment = UITextAlignmentCenter;
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
    dialogLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:dialogLabel];
    
    //Add Miss Samia as Speaker
    currentSpeaker = [[Speaker alloc] initWithName:@"Samia"];
    speakerImageView = [[SpeakerImageView alloc] initWithFrame:CGRectMake(19, 29, 119, 290) speaker:currentSpeaker];
    speakerImageView.contentMode = UIViewContentModeBottomLeft;
    [self.view addSubview:speakerImageView];
    [speakerImageView repeatAnimation:DEFAULT];

    //Adjust placement of record and play buttons
    [recordButton setImage:[UIImage imageNamed:@"Resource/icon_record.png"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"Resource/icon_stop.png"] forState:UIControlStateSelected];
    recordButton.origin = CGPointMake(chalkboard.centerX - recordButton.size.width, chalkboard.origin.y+chalkboard.size.height+3);
    recordButton.selected = NO;
    playButton.origin = CGPointMake(chalkboard.centerX, chalkboard.origin.y+chalkboard.size.height+3);
    [playButton setImage:[UIImage imageNamed:@"Resource/icon_stop.png"] forState:UIControlStateSelected];
    [self.view sendSubviewToBack:screenBackground];
    [self.view bringSubviewToFront:soundButton];
    [self.view bringSubviewToFront:recordButton];
    [self.view bringSubviewToFront:playButton];
    [self.view bringSubviewToFront:restartButton];
    [self.view bringSubviewToFront:homeButton];
    
    //Add bonus level button
    [bonusLevelButton setImage:[UIImage imageNamed:@"Resource/icon_more.png"] forState:UIControlStateNormal];
    bonusLevelButton.frame = CGRectMake(restartButton.origin.x, restartButton.origin.y - restartButton.size.height - 10, bonusLevelButton.size.width,bonusLevelButton.size.height);
    bonusLevelButton.hidden = YES;
    [self.view addSubview:bonusLevelButton];
    [self.view bringSubviewToFront:bonusLevelButton];
    
    // TEMP - turn off background music
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [super.audioManager.backgroundPlayer pause];
    soundButton.selected = YES;
    [userDefaults setBool:YES forKey:@"pauseMusic"];
    
    
    if(DEBUG_DRAW_BORDERS) {
        [self.view drawBorderOnSubviews];
    }
    
    [self startAlphabetPhase];

    recordButton.hidden = YES;
    playButton.hidden = YES;
    //shouldStopSinging = NO;

}

-(void)resetChalkboard {
    [chalkboard removeAllSubviews];
    //Add writing label on the chalkboard
    chalkboardLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, chalkboard.frame.size.width-10, chalkboard.frame.size.height-40)];
    chalkboardLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:150];
    chalkboardLabel.textColor = [UIColor whiteColor];
    chalkboardLabel.backgroundColor = [UIColor clearColor];
    chalkboardLabel.textAlignment = NSTextAlignmentCenter;
    chalkboard.layer.borderColor = [UIColor brownColor].CGColor;
    chalkboard.layer.borderWidth = 3.0f;
    chalkboardLabel.adjustsFontSizeToFitWidth = NO;
    chalkboardLabel.minimumScaleFactor = 0.5;
    chalkboard.userInteractionEnabled = YES;
    [chalkboard addSubview:chalkboardLabel];
    
    //See what subtitle label looks like on the chalkboard
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, chalkboardLabel.size.height, chalkboardLabel.size.width-40, 30)];
    subtitleLabel.font =  [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
    subtitleLabel.textColor = [UIColor whiteColor];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [chalkboard addSubview:subtitleLabel];
    chalkboardNeedsReset = NO;
}
#pragma mark Game Phases

- (void)startAlphabetPhase{
    
    speakerImageView.hidden = NO;
    
    //[self displayDialogTextWithKey:@"ThisIs" animationType:TALK completion:^() {
    
   //     [self singAndSpellArabicAlphabetForDuration: -1 withCompletion:^() {

            [self displayDialogTextWithKey:@"SingAlong" animationType:TALK completion:^() {
                [self startRecordingPhase];

            }];
            
    //    }];
        
   // }];
    
}



-(void)startRecordingPhase {

    //Recording section
    //
    // Set the audio file
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

    recordButton.hidden = NO;
    playButton.hidden = YES;
    recordedPlayedOnce = NO;
    
}

-(void)displayLettersOnChalkboardWithCompletion:(void(^)())completion {
    NSUInteger tileSize = 44;
    
    ArabicLetter *arabicLetter;
    NSString *soundFile;
    ArabicLetterAudioImageView *arabicLetterView;
    
    //Display all the letters on the chalkboard
    letterImageViewArray = [[NSMutableArray alloc] init];
    float delay = 0.1;
    NSUInteger row = 0;
    NSUInteger space = 2;  //allow 2 pixels between rows
    NSUInteger mx = 0;
    
    for (NSUInteger i=0; i<28; i++) {
        if (i%7 == 0) {
            row++;
            mx=0;
        }
        
        arabicLetter = [[ArabicLetter alloc] initWithLetterIndex:i];
        soundFile = [NSString stringWithFormat:@"Speakers/%@/Audio/Letters/%02d.mp3",currentSpeaker.name,i];
        arabicLetterView = [[ArabicLetterAudioImageView alloc] initWithArabicLetter:arabicLetter andAudioManager:self.audioManager withSound:soundFile];
        [arabicLetterView setArabicLetter:arabicLetter];
        mx = mx + tileSize + space;
        
        arabicLetterView.delegate = self;
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(delay*i), dispatch_get_current_queue(), ^{
            
            arabicLetterView.frame = CGRectMake(chalkboard.size.width - mx - space,
                                                tileSize*(row-1) + space*3*(row),
                                                tileSize, tileSize);
            
            [letterImageViewArray addObject:arabicLetterView];

            [chalkboard addSubview:arabicLetterView];
            [chalkboard bringSubviewToFront:arabicLetterView];
            
        });
    }
    
    completion();
}

-(void)startBonusPhase {
    [chalkboard removeAllSubviews];

    [self displayLettersOnChalkboardWithCompletion:^(){ }];
    chalkboardNeedsReset = YES;
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

-(void)singAndSpellArabicAlphabetForDuration:(NSTimeInterval)d withCompletion:(void((^)()))completion{
    chalkboardLabel.text = @"";
    subtitleLabel.text = @"";

    if (d != -1) {
        [player play];
    }
    [self animateAndSingAlphabetsByIndex:0 forSection:1 forDuration:d withCompletion:^() {
        
        [self animateAndSingAlphabetsByIndex:7 forSection:2 forDuration:d withCompletion:^() {

            [self animateAndSingAlphabetsByIndex:14 forSection:3 forDuration:d withCompletion:^() {

                [self animateAndSingAlphabetsByIndex:21 forSection:4 forDuration:d withCompletion:^() {

                        //shouldStopSinging = NO;  //reset
                        completion();
                }];
            }];
        }];
    }];
}



-(void)animateAndSingAlphabetsByIndex:(NSUInteger)index forSection:(NSUInteger)section forDuration:(NSTimeInterval)d withCompletion:(void((^)()) )completion {
    NSString *suffix = [NSString stringWithFormat:@"Arabic%d",section];
    NSTimeInterval duration;
    
    duration = [self getDurationAndPlaySpeakerDialogAudioWithKey:@"AlphabetSong" prefix:currentSpeaker.name suffix:suffix];

    // Don't animate talking if we are playing back
    if (d == -1) {
        [speakerImageView animateWithType:TALK repeatingDuration:duration];
    }
    
    double part;
    for (NSUInteger i=0; i<7; i++) {
        part = ((double)duration - 0.5)/7;
        
        [self performSelector:@selector(displayChalkboardLetterWithLetterIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:part*i];

        /*
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(  ), dispatch_get_current_queue(), ^{
           
           // NSLog(@"ShouldStopSinging: %d",shouldStopSinging);
            
            if (shouldStopSinging == YES) {
                NSLog(@"In loop, should pause the chalkboard");

                return;
            }
            

        });
        */
        index++;
    }
    
    [self performSelector:@selector(finishAnimateAndSingAlphabetWithCompletion:) withObject:completion afterDelay:duration];
    
    /*
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(duration), dispatch_get_current_queue(), ^{
        if (!shouldStopSinging) {
            completion();
        }
    });
    */
}

- (void)displayChalkboardLetterWithLetterIndex:(NSNumber*)letterIndex {    
    ArabicLetter *arabicLetter = [[ArabicLetter alloc] initWithLetterIndex:[letterIndex intValue]];
    chalkboardLabel.text = [NSString stringWithFormat:@"%C",[arabicLetter unicodeGeneral]];
    subtitleLabel.text = arabicLetter.letterName;    
}

- (void)finishAnimateAndSingAlphabetWithCompletion:(void((^)()) )completion  {
    completion();
}

- (void)cancelAnimateAndSingAlphabet {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (IBAction)restartButtonTouched:(id)sender {
    [super restartButtonTouched:sender];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPopViewControllerNotification object:self];
}



-(void)stopRecording {
    // NSLog(@"Stop your singing now!");
    [self cancelAnimateAndSingAlphabet];
    
    
    //shouldStopSinging = YES;
    [self.audioManager stopAudio:@"talking"];
    [speakerImageView stopAnimating];
    [recorder stop];
    
    [self.audioManager setAudioSessionCategory:AVAudioSessionCategorySoloAmbient];
    
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    recordButton.selected = NO;
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    [player setDelegate:self];
    
    durationLabel.text = [NSString stringWithFormat:@"Recorded %.02f seconds",player.duration];
}

- (IBAction)recordButtonTouched:(id)sender {
    
    if (player.playing) {
        [player stop];
        [self.audioManager stopAudio:@"talking"];
        
        [self cancelAnimateAndSingAlphabet];
        
        [speakerImageView stopAnimating];
        
    }
    
    if (!recorder.recording) {
        if (chalkboardNeedsReset) [self resetChalkboard];
        //shouldStopSinging = NO;
        [self.audioManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
                
        // Start recording
        [recorder record];
        [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        recordButton.selected = YES;
        playButton.hidden = YES;
        
        durationLabel.text = @"Recording...";
        [self singAndSpellArabicAlphabetForDuration: -1 withCompletion:^() {
            [self stopRecording];
        }];
        
    } else {  // Stop recording
        [self stopRecording];
    }    
    
    [playButton setEnabled:NO];
}

- (IBAction)playButtonTouched:(id)sender {
    if (!recorder.recording){        
        [self cancelAnimateAndSingAlphabet];

        if (player.playing) { //press stop
            [player stop];
            [self.audioManager stopAudio:@"talking"];

            player.currentTime = 0; // This is disabling pause while replaying. Stop means stop.
            if( [speakerImageView isAnimating]) [speakerImageView stopAnimating];
            NSLog(@"Stopped was pressed during playback, for duration: %f", [player duration]);

            [playButton setTitle:@"Play" forState:UIControlStateNormal];
            playButton.selected = NO;
            [recordButton setEnabled:YES];
        }
        else { // press play
            if (chalkboardNeedsReset) [self resetChalkboard];
            [recordButton setEnabled:NO];

            NSLog(@"Playing back audio recording");
            [self singAndSpellArabicAlphabetForDuration: player.duration withCompletion:^() {

            }];

            [playButton setTitle:@"Stop" forState:UIControlStateNormal];
            playButton.selected = YES;
        }
        
    }

}

- (IBAction)homeButtonTouched:(id)sender {
    [recorder stop];
    [player stop];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [super homeButtonTouched:sender];
}

-(IBAction)bonusButtonTouched:(id)sender{
    // Clear the Chalkboard
    chalkboardLabel.text = @"";
    subtitleLabel.text = @"";
    // Start bonus level
    [self startBonusPhase];
}

-(void)letterImageViewWasTouchedWith:(ArabicLetterImageView *)letterImageView   {
    ArabicLetterAudioImageView *letter = (ArabicLetterAudioImageView*)letterImageView;
    NSTimeInterval duration = [self.audioManager durationOfAudio:letter.letterSoundFile];
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.20, 1.20);
    letter.transform = scaleTransform;
    [speakerImageView animateWithType:TALK repeatingDuration:duration];
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:dialogLabel.font.pointSize];
    dialogLabel.text = letter.arabicLetter.letterName;
}

-(void)letterImageViewTouchesStopped:(ArabicLetterImageView *)letterImageView   {
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.0, 1.0);
    letterImageView.transform = scaleTransform;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    NSLog(@"Finished recording ...");

    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [playButton setEnabled:YES];
    
    playButton.hidden = NO;
    
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    playButton.selected = NO;
    
    [recordButton setEnabled:YES];

    [self.audioManager stopAudio:@"talking"];
    NSLog(@"Stop the animation now because the recorded audio finished already.");

    [self cancelAnimateAndSingAlphabet];
    
    if (recordedPlayedOnce == NO) {
        recordedPlayedOnce = YES;
        
        bonusLevelButton.hidden = NO;
        NSLog(@"Great job recording!");
        NSLog(@"Make the new level icon appear now");
    }
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
