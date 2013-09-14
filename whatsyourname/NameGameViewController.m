//
//  NameGameViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/21/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "NameGameViewController.h"
#import "Speaker.h"
#import "SpeakerImageView.h"
#import "SpeakerList.h"
#import "NameSpellViewController.h"

#define NON_PRIMARY_SPEAKER_IMAGE_SCALE .90
#define MAX_NAME_LENGTH 9
#define HINT_TEXT_SIZE 15
#define DIALOG_LABEL_ZOOM_FACTOR 2.6

@interface NameGameViewController () {

    NSDictionary* yourNameDialogDictionary;
    SpeakerImageView* mainSpeakerImageView;
    NSMutableArray* speakerImageViewArray;
    Speaker* mainSpeaker;
    NSString* playerName;
    UIFont* originalDialogLabelFont;
    UIButton* dialogZoomButton;
}

- (IBAction)dialogLabelTouchDown:(id)sender;
- (IBAction)dialogLabelTouchUp:(id)sender;

@end

@implementation NameGameViewController
@synthesize playerNameArabic;

- (void)addSpeakerImageViewsToView {
    
    CGSize imageSize = CGSizeMake(140,216);
    NSInteger viewWidth = 480;
    NSUInteger index = 0;
    NSInteger leftFrameX = 0;
    NSInteger rightFrameX = 0;
    CGRect frame;
    
    speakerImageViewArray = [[NSMutableArray alloc] initWithCapacity:[SpeakerList sharedInstance].speakerArray.count];
    for (Speaker* speaker in [SpeakerList sharedInstance].speakerArray) {
        
        SpeakerImageView* speakerImageView = [[SpeakerImageView alloc] initWithFrame:CGRectZero
                                                                             speaker:speaker];
        speakerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [speakerImageViewArray addObject:speakerImageView];
        //speakerImageView.backgroundColor = [UIColor redColor];
        if (!mainSpeakerImageView) {
            mainSpeaker = speaker;
            mainSpeakerImageView = speakerImageView;
        }
        
        
        if (index == 0) {
            frame = CGRectMake((viewWidth/2)-70, 99, imageSize.width, imageSize.height);
            leftFrameX = frame.origin.x;
            rightFrameX = frame.origin.x;
        }
        else if ((index % 2) == 0) {
            leftFrameX -= (imageSize.width*NON_PRIMARY_SPEAKER_IMAGE_SCALE-27);
            frame = CGRectMake(leftFrameX, 94, imageSize.width*NON_PRIMARY_SPEAKER_IMAGE_SCALE, imageSize.height*NON_PRIMARY_SPEAKER_IMAGE_SCALE);
        }
        else if ((index % 2) == 1) {
            rightFrameX += (imageSize.width)-27;
            frame = CGRectMake(rightFrameX, 94, imageSize.width*NON_PRIMARY_SPEAKER_IMAGE_SCALE, imageSize.height*NON_PRIMARY_SPEAKER_IMAGE_SCALE);
        }
        
        speakerImageView.frame = frame;
        
        //        /speakerImageView.centerX = self.view.centerX;
        //speakerImageView.bottom = self.view.bottom;
        [self.view addSubview:speakerImageView];
        [speakerImageView repeatAnimation:DEFAULT];
        
        index++;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"YourNameDialog"] ofType:@"plist"];
    
    yourNameDialogDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    originalDialogLabelFont = dialogLabel.font;
    dialogLabel.adjustsFontSizeToFitWidth = YES;
    
    dialogZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dialogZoomButton.frame = dialogLabel.bounds;
    
    [dialogZoomButton addTarget:self action:@selector(dialogLabelTouchDown:) forControlEvents:UIControlEventTouchDown];
    [dialogZoomButton addTarget:self action:@selector(dialogLabelTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [dialogZoomButton addTarget:self action:@selector(dialogLabelTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    

    UIImage *textFieldBackground = [[UIImage imageNamed:@"Resource/text_box_bg.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    nameTextField.background = textFieldBackground;
    
    
    [self addSpeakerImageViewsToView];
    

    goodByeButton.hidden = YES;
	nameTextField.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"Level4Unlocked"];


    if (nameTextField.hidden) {
        [self displayDialogTextWithKey:@"Now" animateAllSpeakers:NO completion:^() {
            
            [self displayDialogTextWithKey:@"Whats" animateAllSpeakers:YES completion:^() {
                                
                [self displayDialogTextWithKey:@"Write" animateAllSpeakers:NO completion:^() {
                    
                    nameTextField.hidden = NO;
                    
                }];
                                
            }];
            
        }];
    }
    else {
        
        goodByeButton.hidden = NO;
        
        [self displayDialogTextWithKey:@"Another" animateAllSpeakers:NO completion:^() {

        }];
                
    }
    
}

- (IBAction)restartButtonTouched:(id)sender {
    [super restartButtonTouched:sender];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPopViewControllerNotification object:self];
}



- (void)pushSpellController {

    [self performSegueWithIdentifier:@"SpellSegue" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[NameSpellViewController class]]) {
        NameSpellViewController *spellVC = segue.destinationViewController;
        spellVC.playerName = playerName;
    }
}

- (void)displayDialogTextWithKey:(NSString*)key animateAllSpeakers:(BOOL)allspeakers completion:(void(^)())completion {
    
    NSDictionary* dialogDictionary = [yourNameDialogDictionary objectForKey:key];
    if (!dialogDictionary)
        return;

    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = [dialogDictionary objectForKey:@"Arabic"];

    if ([text rangeOfString:@"@name"].location != NSNotFound) {
        text = [text stringByReplacingOccurrencesOfString:@"@name" withString:playerName];
    }
    if ([arabicText rangeOfString:@"@name"].location != NSNotFound) {
        
        if (playerNameArabic) {
            arabicText = [arabicText stringByReplacingOccurrencesOfString:@"@name" withString:playerNameArabic];
        }
        else {
            arabicText = [arabicText stringByReplacingOccurrencesOfString:@"@name" withString:@""];
        }
    }

    //Don't change text if the hint text is being displayed
    if (!dialogZoomButton.superview) {
        dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:dialogLabel.font.pointSize];
        dialogLabel.text = text;
    }
   
    NSTimeInterval dialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:mainSpeaker.name suffix:@"English"];
    
    if (allspeakers) {
        for (SpeakerImageView* s in speakerImageViewArray) {
            [s animateWithType:TALK repeatingDuration:dialogDuration];
        }
    }
    else {
        [mainSpeakerImageView animateWithType:TALK repeatingDuration:dialogDuration];
    }

    
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(dialogDuration), dispatch_get_main_queue(), ^{
        
        //Don't change text if the hint text is being displayed
        if (!dialogZoomButton.superview) {
            dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:dialogLabel.font.pointSize];
            dialogLabel.text = arabicText;
        }
        
        NSTimeInterval dialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:mainSpeaker.name suffix:@"Arabic"];
        
        if (allspeakers) {
            for (SpeakerImageView* s in speakerImageViewArray) {
                [s animateWithType:TALK repeatingDuration:dialogDuration];
            }
        }
        else {
            [mainSpeakerImageView animateWithType:TALK repeatingDuration:dialogDuration];
        }
        
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(dialogDuration), dispatch_get_main_queue(), ^{
        
            completion();
            
        });
        
    });
    

    
}


- (IBAction)goodByeButtonTouched:(id)sender {
    nameTextField.hidden = YES;
    goodByeButton.hidden = YES;
    [self displayDialogTextWithKey:@"Nice" animateAllSpeakers:NO completion:^() {

        [self displayDialogTextWithKey:@"Bye" animateAllSpeakers:YES completion:^() {
            
            for (SpeakerImageView* speakerImageView in speakerImageViewArray) {
                [speakerImageView repeatAnimation:BYE];
            }
            
        }];
    }];
    
}

/*
- (IBAction)restartButtonTouched:(id)sender {
    [self performSegueWithIdentifier:@"RestartSegue" sender:self];
}
*/

- (void)dialogLabelTouchDown:(id)sender {
    
    
    [dialogLabel.superview bringSubviewToFront:dialogLabel];
    
    CGRect f = dialogLabel.frame;
    f.size = CGSizeMake(f.size.width,f.size.height*DIALOG_LABEL_ZOOM_FACTOR);
    dialogLabel.frame = f;
    
    dialogLabel.font = [dialogLabel.font fontWithSize:dialogLabel.font.pointSize+13];
    dialogLabel.numberOfLines = 4;
    
    dialogLabel.backgroundColor = RGBA(255, 255, 255, .70);
    
    /*
    //dialogLabel.transform = CGAffineTransformScale(dialogLabel.transform, 0.35, 0.35);
    [UIView animateWithDuration:0.5 animations:^{
        dialogLabel.transform = CGAffineTransformScale(dialogLabel.transform, DIALOG_LABEL_ZOOM_FACTOR, DIALOG_LABEL_ZOOM_FACTOR);
    }];


    [UIView animateWithDuration: .5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         
                         
                     }
                     completion:^(BOOL finished){
                        
                     }];
 */
    
    
    
}
- (void)dialogLabelTouchUp:(id)sender {
    
    CGRect f = dialogLabel.frame;
    f.size = CGSizeMake(f.size.width,f.size.height*(1.0/DIALOG_LABEL_ZOOM_FACTOR));
    dialogLabel.frame = f;

    dialogLabel.font = [dialogLabel.font fontWithSize:HINT_TEXT_SIZE];
    dialogLabel.numberOfLines = 2;
    
    dialogLabel.backgroundColor = [UIColor clearColor];
    
    /*
    [UIView animateWithDuration:0.5 animations:^{
        dialogLabel.transform = CGAffineTransformIdentity;
    }];

    
    [UIView animateWithDuration: .5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
     */
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAX_NAME_LENGTH || returnKey;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [dialogLabel addSubview:dialogZoomButton];
    
    NSString* text = @"Hint: You can use capitals or numbers like this: S = saad, D = daad, T = Taa,\nZ = Thaa, 2 = alef hamza, 3 = 'ein, 5 = ghein, 7 or H = Ha";
    
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:HINT_TEXT_SIZE];
    dialogLabel.text = text;
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [dialogZoomButton removeFromSuperview];
    
    dialogLabel.font = [UIFont fontWithName:originalDialogLabelFont.fontName size:originalDialogLabelFont.pointSize];
    dialogLabel.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    [textField resignFirstResponder];
    
    if (textField.text.length>0) {
        playerName = textField.text;
        [self pushSpellController];
    }
    
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [nameTextField resignFirstResponder];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
