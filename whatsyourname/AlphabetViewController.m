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
#import "ButtonExpander.h"

#define CHALKBOARD_LETTER_DELAY 0.1

@interface AlphabetViewController () <ArabicLetterAudioImageViewDelegate> {
    
    IBOutlet GameUIButton* recordButton;
    IBOutlet GameUIButton* playButton;
    IBOutlet GameUIButton* bonusLevelButton;
    //IBOutlet UILabel* durationLabel;
    
    AVAudioRecorder* recorder;
    AVAudioPlayer *player;
    
    UIView *view;
    UIImageView *chalkboard;
    UILabel *dialogLabel;
    UILabel *chalkboardLabel;
    UILabel *subtitleLabel;
    ButtonExpander *settingsButtonExpander;
    
    NSString *unicodeNameStringForSpelling;
    Speaker* currentSpeaker;
    SpeakerImageView* speakerImageView;
    float songDelay;
    BOOL recordedPlayedOnce;
    //BOOL shouldStopSinging;
    BOOL chalkboardNeedsReset;
    BOOL backgroundPlayerPlaying;
}

- (IBAction)recordButtonTouched:(id)sender;
- (IBAction)playButtonTouched:(id)sender;
- (IBAction)bonusButtonTouched:(id)sender;

@end

@implementation AlphabetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super.audioManager prepareAudioWithPath:@"Speakers/Samia/Audio/AlphabetSongArabic.mp3"];
    
    currentSpeaker = [[Speaker alloc] initWithName:@"Samia"];
    //Add background image
    //view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenBounds.width, self.screenBounds.height)];
    
    NSString* backgroundPath = [NSString stringWithFormat:@"Speakers/%@/Images/background.png",currentSpeaker.name];
    UIImageView* screenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundPath]];
    screenBackground.frame = CGRectMake(0,0,self.screenBounds.width, self.screenBounds.height);
    [self.view addSubview:screenBackground];

    //Add Chalkboard in UIView section
    UIImage *cImg = [[UIImage imageNamed:@"Resource/chalkboard.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:5];
    chalkboard = [[UIImageView alloc] initWithImage:cImg];
    chalkboard.frame = CGRectMake(144, 65, 331, 210);
    [self.view addSubview:chalkboard];

    [self resetChalkboard];

    //Add dialog view in UIView section
    dialogLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 448, 48)];
    dialogLabel.backgroundColor = [UIColor clearColor];
    dialogLabel.textAlignment = NSTextAlignmentCenter;
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
    dialogLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:dialogLabel];
    
    //Add Miss Samia as Speaker
    speakerImageView = [[SpeakerImageView alloc] initWithFrame:CGRectMake(32, 25, 119, 290) speaker:currentSpeaker];
    speakerImageView.contentMode = UIViewContentModeBottomLeft;
    [self.view addSubview:speakerImageView];
    [speakerImageView repeatAnimation:DEFAULT];

    //Adjust placement of record and play buttons
    [recordButton setImage:[UIImage imageNamed:@"Resource/icon_record.png"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"Resource/icon_stop.png"] forState:UIControlStateSelected];
    recordButton.origin = CGPointMake(chalkboard.centerX - recordButton.size.width, chalkboard.origin.y+chalkboard.size.height+5);
    recordButton.selected = NO;
    playButton.origin = CGPointMake(chalkboard.centerX, chalkboard.origin.y+chalkboard.size.height+5);
    [playButton setImage:[UIImage imageNamed:@"Resource/icon_stop.png"] forState:UIControlStateSelected];
    
    //Set up the settings icon expanders
    settingsButtonExpander = [[ButtonExpander alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [settingsButtonExpander setImage:[UIImage imageNamed:@"Resource/icon_settings.png"] forState:UIControlStateNormal];
    [settingsButtonExpander setFrame:CGRectMake( 3,
                                                self.screenBounds.height - settingsButtonExpander.imageView.image.size.height-3,
                                                settingsButtonExpander.imageView.image.size.width,
                                                settingsButtonExpander.imageView.image.size.height)];
    [settingsButtonExpander setChildButtonsArray:[[NSArray alloc] initWithObjects: homeButton, restartButton, nil]];
    [self.view addSubview:settingsButtonExpander];
    
    [self.view sendSubviewToBack:screenBackground];
    [self.view bringSubviewToFront:settingsButtonExpander];
    [self.view bringSubviewToFront:recordButton];
    [self.view bringSubviewToFront:playButton];
    
    //Add bonus level button
    [bonusLevelButton setImage:[UIImage imageNamed:@"Resource/icon_star.png"] forState:UIControlStateNormal];
    bonusLevelButton.frame = CGRectMake(chalkboard.origin.x+chalkboard.size.width - bonusLevelButton.size.width - 5, recordButton.origin.y, bonusLevelButton.size.width,bonusLevelButton.size.height);
    bonusLevelButton.hidden = YES;
    [self.view addSubview:bonusLevelButton];
    [self.view bringSubviewToFront:bonusLevelButton];

    if(DEBUG_DRAW_BORDERS) {
        [self.view drawBorderOnSubviews];
    }
    
    [self startAlphabetPhase];

    recordButton.hidden = YES;
    playButton.hidden = YES;
    //shouldStopSinging = NO;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    backgroundPlayerPlaying = [AudioManager sharedInstance].backgroundPlayer.isPlaying;
    
    if (backgroundPlayerPlaying) {
        [[AudioManager sharedInstance].backgroundPlayer pause];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (backgroundPlayerPlaying) {
        [[AudioManager sharedInstance].backgroundPlayer play];
    }
}

-(void)resetChalkboard {
    [chalkboard removeAllSubviews];
    //Add writing label on the chalkboard
    chalkboardLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, chalkboard.frame.size.width-10, chalkboard.frame.size.height-40)];
    chalkboardLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:130];
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
    
    [self displayDialogTextWithKey:@"ThisIs" animationType:TALK completion:^() {
        
        [self singAndSpellArabicAlphabetForDuration: -1 withCompletion:^() {

            [self displayDialogTextWithKey:@"SingAlong" animationType:TALK completion:^() {
                [self startRecordingPhase];
                recordedPlayedOnce = [[NSUserDefaults standardUserDefaults] boolForKey:@"BonusAlphbetsUnlocked"]; 
                if (recordedPlayedOnce) bonusLevelButton.hidden = NO;
                

            }];
            
        }];
        
    }];
    
}



-(void)startRecordingPhase {

    //Recording section
    //
    // Set the audio file
    
    /*
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"recorderAudio.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    */
    
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"recorderAudio.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    // Setup audio session
    //AVAudioSession *session = [AVAudioSession sharedInstance];
    //[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    //[recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    //[recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    //[recordSettings setValue:[NSNumber numberWithInt: AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    //[recordSettings setValue:[NSNumber numberWithInt: 16] forKey:AVEncoderBitRateKey];
    //[recordSettings setObject:[NSNumber numberWithInt:AVAudioQualityLow] forKey: AVEncoderAudioQualityKey];

    // Initiate and prepare the recorder
    NSError* error;
    recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    
    if (error) {
        NSLog(@"AVAudioRecorder error: %@",error);
    }
    
    recorder.delegate = self;
    //recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    recordButton.hidden = NO;
    playButton.hidden = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BonusAlphbetsUnlocked"] == YES) {
        recordedPlayedOnce = YES;
    } else {
        recordedPlayedOnce = NO;
    }
    
}


-(void)displayLettersOnChalkboardWithCompletion:(void(^)())completion {
    NSUInteger tileSize = 44;
    ArabicLetter *arabicLetter;
    NSString *soundFile;
    ArabicLetterAudioImageView *arabicLetterView;
    
    //Display all the letters on the chalkboard
    NSUInteger row = 0;
    NSUInteger space = 2;  //allow 2 pixels between rows
    NSUInteger mx = 0;
    
    for (NSUInteger i=0; i<28; i++) {
        if (i%7 == 0) {
            row++;
            mx=0;
        }
        
        arabicLetter = [[ArabicLetter alloc] initWithLetterIndex:i];
        soundFile = [NSString stringWithFormat:@"Speakers/%@/Audio/Letters/%02u.mp3",currentSpeaker.name,(unsigned int)i];
        arabicLetterView = [[ArabicLetterAudioImageView alloc] initWithArabicLetter:arabicLetter andAudioManager:self.audioManager withSound:soundFile];
        [arabicLetterView setArabicLetter:arabicLetter];
        mx = mx + tileSize + space;
        
        arabicLetterView.delegate = self;
        
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(CHALKBOARD_LETTER_DELAY*i), dispatch_get_main_queue(), ^{
            
            arabicLetterView.frame = CGRectMake(chalkboard.size.width - mx - space,
                                                tileSize*(row-1) + space*3*(row),
                                                tileSize, tileSize);
            
            [chalkboard addSubview:arabicLetterView];
            [chalkboard bringSubviewToFront:arabicLetterView];
            
        });
        
    }
    
    completion();
}

-(void)reenableRecordAndPlay {
    [recordButton setEnabled:YES];
    [playButton setEnabled:YES];
    [bonusLevelButton setEnabled:YES];
}

-(void)startBonusPhase {
    [recordButton setEnabled:NO];
    [playButton setEnabled:NO];
    [bonusLevelButton setEnabled:NO];
    
    [self displayLettersOnChalkboardWithCompletion:^(){ }];
    
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(CHALKBOARD_LETTER_DELAY*28), dispatch_get_main_queue(), ^{
        [self reenableRecordAndPlay];
    });

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

    dispatch_after(DISPATCH_SECONDS_FROM_NOW(englishDialogDuration), dispatch_get_main_queue(), ^{
        
        dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:dialogLabel.font.pointSize];
        dialogLabel.text = arabicText;
        [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:currentSpeaker.name suffix:@"Arabic"];
        
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(arabicDialogDuration), dispatch_get_main_queue(), ^{
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
    NSString *suffix = [NSString stringWithFormat:@"Arabic%d",(unsigned int)section];
    NSTimeInterval duration;
    
    duration = [self getDurationAndPlaySpeakerDialogAudioWithKey:@"AlphabetSong" prefix:currentSpeaker.name suffix:suffix];

    // Don't animate talking if we are playing back
    if (d == -1) {
        [speakerImageView animateWithType:TALK repeatingDuration:duration];
    }
    
    double part;
    for (NSUInteger i=0; i<7; i++) {
        part = ((double)duration - 0.5)/7;
        
        [self performSelector:@selector(displayChalkboardLetterWithLetterIndex:) withObject:[NSNumber numberWithInt:(int)index] afterDelay:part*i];

        /*
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(  ), dispatch_get_main_queue(), ^{
           
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
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(duration), dispatch_get_main_queue(), ^{
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

/* Completion block for performSelector withDeplay method */
- (void)finishAnimateAndSingAlphabetWithCompletion:(void((^)()) )completion  {
    completion();
}

/* Assist method to cancel previous requests to performSelector withDeplay method */
- (void)cancelAnimateAndSingAlphabet {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)restartButtonTouched {
    [super restartButtonTouched];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPopViewControllerNotification object:self];
}



-(void)stopRecording {
    // NSLog(@"Stop your singing now!");
    [self cancelAnimateAndSingAlphabet];
    
    
    //shouldStopSinging = YES;
    [self.audioManager stopAudio:@"talking"];
    [speakerImageView stopAnimating];
    [recorder stop];
    
    //[self.audioManager setAudioSessionCategory:AVAudioSessionCategorySoloAmbient];
    
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    recordButton.selected = NO;
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    [player setDelegate:self];
    
    //durationLabel.text = [NSString stringWithFormat:@"Recorded %.02f seconds",player.duration];
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
        //[self.audioManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
                
        // Start recording
        [recorder record];
        
        if (recorder.recording) {
            [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
            recordButton.selected = YES;
            playButton.hidden = YES;
            
            if (bonusLevelButton.hidden==NO) [bonusLevelButton setEnabled:NO];
            
            //durationLabel.text = @"Recording...";
            [self singAndSpellArabicAlphabetForDuration: -1 withCompletion:^() {
                [self stopRecording];
            }];
            
            [playButton setEnabled:NO];
        } else {
            if (bonusLevelButton.hidden==NO) [bonusLevelButton setEnabled:YES];
            
        }
        
    } else {  // Stop recording
        [self stopRecording];
        
        [playButton setEnabled:NO];
    }    
    

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
            
            if (bonusLevelButton.hidden==NO) [bonusLevelButton setEnabled:YES];

        }
        else { // press play
            if (chalkboardNeedsReset) [self resetChalkboard];
            [recordButton setEnabled:NO];

            NSLog(@"Playing back audio recording");
            [self singAndSpellArabicAlphabetForDuration: player.duration withCompletion:^() {

            }];

            [playButton setTitle:@"Stop" forState:UIControlStateNormal];
            playButton.selected = YES;
            
            if (bonusLevelButton.hidden==NO) [bonusLevelButton setEnabled:NO];

        }
        
    }

}

- (void)homeButtonTouched {
    [recorder stop];
    [player stop];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [super homeButtonTouched];
}

-(IBAction)bonusButtonTouched:(id)sender{
    // Clear the Chalkboard
    [chalkboard removeAllSubviews];

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
    if (bonusLevelButton.hidden==NO) [bonusLevelButton setEnabled:YES];
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur: %@",error);
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    [self stopRecording];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    playButton.selected = NO;
    
    [recordButton setEnabled:YES];

    [self.audioManager stopAudio:@"talking"];
    NSLog(@"Stop the animation now because the recorded audio finished already.");

    [self cancelAnimateAndSingAlphabet];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    recordedPlayedOnce =  [userDefaults boolForKey:@"BonusAlphbetsUnlocked"];
    if (bonusLevelButton.hidden==NO) [bonusLevelButton setEnabled:YES];

    if (recordedPlayedOnce == NO) {
        recordedPlayedOnce = YES;
        [userDefaults setBool:YES forKey:@"BonusAlphbetsUnlocked"];
        
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
