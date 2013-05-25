//
//  YourNameViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/21/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "YourNameViewController.h"
#import "UIView+Additions.h"
#import "Speaker.h"
#import "SpeakerImageView.h"
#import "SpeakerList.h"

@interface YourNameViewController () {
    NSDictionary* yourNameDialogDictionary;
    SpeakerImageView* mainSpeakerImageView;
}

@end

@implementation YourNameViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"YourNameDialog"] ofType:@"plist"];
    
    yourNameDialogDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    CGSize screenBounds = CGSizeMake(480,320);
    UIImageView* screenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/bg.jpg"]];
    screenBackground.frame = CGRectMake(0,0,screenBounds.width,screenBounds.height);
    screenBackground.alpha = 0.8;
    [self.view addSubview:screenBackground];
    [self.view sendSubviewToBack:screenBackground];

    [self addSpeakerImageViewsToView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    goodByeButton.hidden = YES;
	nameTextField.hidden = YES;
    restartButton.hidden = YES;
    
    [self displayDialogTextWithKey:@"Now" completion:^() {
        
        [self displayDialogTextWithKey:@"Whats" completion:^() {
            
            
            [self displayDialogTextWithKey:@"Write" completion:^() {
                
                nameTextField.hidden = NO;
                
            }];
            
            
        }];
        
    }];
    
}

- (void)addSpeakerImageViewsToView {
    
    CGSize imageSize = CGSizeMake(140,216);
    NSInteger viewWidth = 480;
    NSUInteger index = 0;
    NSInteger leftFrameX = 0;
    NSInteger rightFrameX = 0;
    CGRect frame;
    for (Speaker* speaker in [SpeakerList sharedInstance].speakerArray) {
        
        SpeakerImageView* speakerImageView = [[SpeakerImageView alloc] initWithFrame:CGRectZero
                                                                             speaker:speaker];
        //speakerImageView.backgroundColor = [UIColor redColor];
        if (!mainSpeakerImageView) {
            mainSpeakerImageView = speakerImageView;
        }
        
        
        if (index == 0) {
            frame = CGRectMake((viewWidth/2)-70, 94, imageSize.width, imageSize.height);
            leftFrameX = frame.origin.x;
            rightFrameX = frame.origin.x;
        }
        else if ((index % 2) == 1) {
            leftFrameX -= (imageSize.width - 20);
            frame = CGRectMake(leftFrameX, 94, imageSize.width, imageSize.height);
        }
        else if ((index % 2) == 0) {
            rightFrameX += (imageSize.width - 20);
            frame = CGRectMake(rightFrameX, 94, imageSize.width, imageSize.height);
        }
        
        speakerImageView.frame = frame;
        
//        /speakerImageView.centerX = self.view.centerX;
        //speakerImageView.bottom = self.view.bottom;
        [self.view addSubview:speakerImageView];
        [speakerImageView animateWithDefaultAnimation];
        
        index++;
    }
    
}

- (void)displayGreetingWithName:(NSString*)name {
    
    NSDictionary* dialogDictionary = [yourNameDialogDictionary objectForKey:@"Nice"];
 
    NSString* helloEnglish = [NSString stringWithFormat:[dialogDictionary objectForKey:@"English"],name];
    NSString* helloArabic =  [dialogDictionary objectForKey:@"Arabic"];
    NSTimeInterval duration = [[dialogDictionary objectForKey:@"Duration"] floatValue];
    
    [self displayEnglishText:helloEnglish arabicText:helloArabic duration:duration completion:^() {
        
        [self displayDialogTextWithKey:@"Another" completion:^() {
            
            nameTextField.hidden = NO;
            goodByeButton.hidden = NO;
           
        }];
        
    }];
    
}

- (void)displayDialogTextWithKey:(NSString*)key completion:(void(^)())completion {
    
    NSDictionary* dialogDictionary = [yourNameDialogDictionary objectForKey:key];
    if (!dialogDictionary)
        return;
    
    NSTimeInterval duration = [[dialogDictionary objectForKey:@"Duration"] floatValue];
    
    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = [dialogDictionary objectForKey:@"Arabic"];

    [self displayEnglishText:text arabicText:arabicText duration:duration completion:completion];
}

- (void)displayEnglishText:(NSString*)englishText arabicText:(NSString*)arabicText duration:(NSTimeInterval)duration completion:(void(^)())completion {
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:28];
    dialogLabel.text = englishText;
    
    
    [mainSpeakerImageView animateWithType:TALK duration:duration*2];
    dialogLabel.alpha = .99;
    [UIView animateWithDuration: duration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         dialogLabel.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                         dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:28];
                         dialogLabel.text = arabicText;
                         dialogLabel.alpha = .99;
                         
                         [UIView animateWithDuration: duration
                                               delay: 0.0
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              dialogLabel.alpha = 1;
                                          }
                                          completion:^(BOOL finished){
                                              
                                              completion();
                                          }];
                         
                         
                     }];
    
}


- (IBAction)goodByeButtonTouched:(id)sender {
    nameTextField.hidden = YES;
    goodByeButton.hidden = YES;
    [self displayDialogTextWithKey:@"Bye" completion:^() {
        
        restartButton.hidden = NO;
        
    }];
    
}

- (IBAction)restartButtonTouched:(id)sender {
    [self performSegueWithIdentifier:@"RestartSegue" sender:self];
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {    
    [textField resignFirstResponder];
    
    if (textField.text.length>0) {
        [self displayGreetingWithName:textField.text];
    }
    
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [nameTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
