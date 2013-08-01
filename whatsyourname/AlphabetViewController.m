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
    IBOutlet UILabel* durationLabel;
    
    AVAudioRecorder* recorder;
    AVAudioPlayer *player;
    
    UIView *view;
    UIImageView *chalkboard;
//    UILabel *dialogLabel;
    UILabel *chalkboardLabel;
    NSString *unicodeNameStringForSpelling;
    Speaker* currentSpeaker;
    SpeakerImageView* speakerImageView;
    float songDelay;
}

- (IBAction)recordButtonTouched:(id)sender;
- (IBAction)playButtonTouched:(id)sender;

@end

@implementation AlphabetViewController

- (void)viewDidLoad
{
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

    //Add writing label on the chalkboard
    chalkboardLabel = [[UILabel alloc]initWithFrame:CGRectMake(chalkboard.origin.x+5, chalkboard.origin.y+5, chalkboard.frame.size.width-10, chalkboard.frame.size.height-10)];
    chalkboardLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:150];
    chalkboardLabel.textColor = [UIColor whiteColor];
    chalkboardLabel.backgroundColor = [UIColor clearColor];
    chalkboardLabel.textAlignment = NSTextAlignmentCenter;
    chalkboard.layer.borderColor = [UIColor brownColor].CGColor;
    chalkboard.layer.borderWidth = 3.0f;
    chalkboardLabel.adjustsFontSizeToFitWidth = NO;
    chalkboardLabel.minimumScaleFactor = 0.5;
    [self.view addSubview:chalkboardLabel];

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
    recordButton.origin = CGPointMake(chalkboard.centerX - recordButton.size.width, chalkboard.origin.y+chalkboard.size.height+3);
    playButton.origin = CGPointMake(chalkboard.centerX, chalkboard.origin.y+chalkboard.size.height+3);
    [self.view sendSubviewToBack:screenBackground];
    [self.view bringSubviewToFront:soundButton];
    [self.view bringSubviewToFront:recordButton];
    [self.view bringSubviewToFront:playButton];
    [self.view bringSubviewToFront:restartButton];
    [self.view bringSubviewToFront:homeButton];
    
    recordButton.hidden = YES;
    playButton.hidden = YES;
    soundButton.selected = NO;
    [soundButton setImage:[UIImage imageNamed:@"Resource/sound_off.png"] forState:UIControlStateSelected];
    
    
    if(DEBUG_DRAW_BORDERS) {
        [self.view drawBorderOnSubviews];
    }
    
    [self startAlphabetPhase];
 
    [self startRecordingPhase];

    recordButton.hidden = YES;
    playButton.hidden = YES;
}

#pragma mark Game Phases

- (void)startAlphabetPhase{
    
    speakerImageView.hidden = NO;
    
    [self displayDialogTextWithKey:@"ThisIs" animationType:TALK completion:^() {
        
        [self singAndSpellArabicAlphabetWithCompletion:^() {

            [self displayDialogTextWithKey:@"SingAlong" animationType:TALK completion:^() {

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

-(void)singAndSpellArabicAlphabetWithCompletion:(void((^)()))completion{
    [self animateAndSingAlphabetsByIndex:0 forSection:1 withCompletion:^() {
        [self animateAndSingAlphabetsByIndex:7 forSection:2 withCompletion:^() {
            [self animateAndSingAlphabetsByIndex:14 forSection:3 withCompletion:^() {
                [self animateAndSingAlphabetsByIndex:21 forSection:4 withCompletion:^() {
                }];
            }];
        }];
    }];
}

-(void)animateAndSingAlphabetsByIndex:(NSUInteger)index forSection:(NSUInteger)section withCompletion:(void((^)()) )completion {

    NSString *suffix = [NSString stringWithFormat:@"Arabic%d",section];
    NSString *prevSuffix = [NSString stringWithFormat:@"Arabic%d",section-1];
    NSTimeInterval sectionDuration=0;
    if (section == 1) {
        songDelay = 0;
    } else if(section > 1) {
        sectionDuration = [self getDurationDialogAudioWithKey:@"AlphabetSong" prefix:currentSpeaker.name suffix:prevSuffix];
        songDelay = songDelay + sectionDuration;
    }
    
    NSTimeInterval duration = [self getDurationDialogAudioWithKey:@"AlphabetSong" prefix:currentSpeaker.name suffix:suffix];

    dispatch_after(DISPATCH_SECONDS_FROM_NOW(songDelay), dispatch_get_current_queue(), ^{
    
        NSTimeInterval duration = [self getDurationAndPlaySpeakerDialogAudioWithKey:@"AlphabetSong" prefix:currentSpeaker.name suffix:suffix];
        [speakerImageView animateWithType:TALK repeatingDuration:duration];
    });
    for (NSUInteger i=0; i<7; i++) {
        
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(((duration-0.5)/7*i) + songDelay), dispatch_get_current_queue(), ^{
            
            ArabicLetter *arabicLetter = [[ArabicLetter alloc] initWithLetterIndex:index];
            chalkboardLabel.text = [NSString stringWithFormat:@"%C",[arabicLetter unicodeGeneral]];
        });
        index++;
    }
    
    completion();
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

- (IBAction)homeButtonTouched:(id)sender {
    [recorder stop];
    [player stop];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [super homeButtonTouched:sender];
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
