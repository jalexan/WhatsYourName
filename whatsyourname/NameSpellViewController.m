//
//  NameSpellViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "NameSpellViewController.h"
#import "ArabicLetter.h"
#import "ArabicLetterImageView.h"
#import "SpeakerList.h"

@interface NameSpellViewController () {
    NSDictionary* yourNameDialogDictionary;
    Speaker* mainSpeaker;
    NSArray* arabicLettersArray;
    NSMutableArray* letterImageViewArray;
}

@end

@implementation NameSpellViewController
@synthesize playerName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!playerName)
        return;
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"YourNameDialog"] ofType:@"plist"];
    
    mainSpeaker = [SpeakerList sharedInstance].speakerArray[0];
    yourNameDialogDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    
    
    //TODO: use translatedLetterArrayForEnglishName instead of fake hardcoded array
    //arabicLettersArray = [self translatedLetterArrayForEnglishName:playerName];
    arabicLettersArray = @[@10,@22,@25,@26,@27];

    [self createLetterImageViewArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!playerName)
        return;

    [self displayDialogTextWithKey:@"LikeThis" completion:^() {
        
        [self animateArabicNameImageViewWithIndex:0 limit:arabicLettersArray.count-1 completion:^() {
            
            dialogLabel.alpha = .99;
            [UIView animateWithDuration: 4
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 dialogLabel.alpha = 1;
                             }
                             completion:^(BOOL finished){
                                 
                                 [self.navigationController popViewControllerAnimated:YES];
                                 
                             }];
            
        }];
        
    }];
    
}

- (NSArray*)translatedLetterArrayForEnglishName:(NSString*)name {
    NSMutableArray* letters = [[NSMutableArray alloc] init];
    
    //TODO: Given the name passed in, return an array of arabic letter indexes
    //letter index 0 corresponds to the arabic letter "alef"
    
    //Loop through each charater
    for (NSUInteger i=0;i<name.length;i++) {
        unichar currentChar = [name characterAtIndex:i];
        NSLog(@"%C",currentChar);
    }
    
    
    
    return letters;
}

- (void)createLetterImageViewArray {
    NSUInteger numberOfLetters = arabicLettersArray.count;
    letterImageViewArray = [NSMutableArray arrayWithCapacity:numberOfLetters];
        
    CGSize letterImageSize = CGSizeMake(50, 50);
    NSInteger originY = 0;
    NSInteger heightToDivideEvenly = letterContainerView.height - letterImageSize.height; //Distance of origin of lowest slot to top of container
    
    NSInteger originYStep = 0;
    NSInteger numberOfSteps = 0;
    
    if (numberOfLetters>2) {
        if (numberOfLetters%2==0) { //Even # of letters
            numberOfSteps = (numberOfLetters/2)-1;
        }
        else { //Odd # of letters
            numberOfSteps = (numberOfLetters/2);
        }
        originYStep = heightToDivideEvenly/numberOfSteps;
    }
    else {
        numberOfSteps = 0;
        originYStep = heightToDivideEvenly;
    }
    
    
    for (int i=0;i<numberOfLetters;i++) {
        
        if (i>0) {
            if (i<=numberOfSteps) { //On the way down
                originY += originYStep;
            }
            else if (numberOfLetters%2==1 || i!=(numberOfSteps+1)) {
                originY -= originYStep;
            }
        }
        
        
        
        CGRect r = CGRectMake((letterContainerView.width-letterImageSize.width)-(letterImageSize.width*i), originY, letterImageSize.width, letterImageSize.height);
        ArabicLetter* l = [[ArabicLetter alloc] initWithLetterIndex:[arabicLettersArray[i] intValue]];
        ArabicLetterImageView* letterImageView = [[ArabicLetterImageView alloc] initWithArabicLetter:l];
        letterImageView.alpha = 0;
        
        letterImageView.frame = r;
        [letterContainerView addSubview:letterImageView];
        
        [letterImageViewArray addObject:letterImageView];
     
    }

}

- (void)animateArabicNameImageViewWithIndex:(NSUInteger)index limit:(NSUInteger)limit completion:(void(^)())completion {
    
    if (index>limit) {
        completion();
        return;
    }

    
    //Arabic Tiles
    NSUInteger letterIndex = [[arabicLettersArray objectAtIndex:index] intValue];
    ArabicLetter* letter = [[ArabicLetter alloc] initWithLetterIndex:letterIndex];
    letter.slotPosition = index;
    
    ArabicLetterImageView* letterImageView = letterImageViewArray[index];
    
    
    //Spell out each letter in dialog label
    if (index==0) arabicSpellLabel.text = @"";
    arabicSpellLabel.text = [NSString stringWithFormat:@"%@%C",arabicSpellLabel.text,letter.unicodeGeneral];
        
    dialogLabel.alpha = .99;
    [UIView animateWithDuration: 2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         dialogLabel.alpha = 1;
                         letterImageView.alpha = 1;
                         
                     }
                     completion:^(BOOL finished){
                         [self animateArabicNameImageViewWithIndex:index+1 limit:limit completion:completion];
                     }];
    
}

- (void)displayDialogTextWithKey:(NSString*)key completion:(void(^)())completion {
    
    NSDictionary* dialogDictionary = [yourNameDialogDictionary objectForKey:key];
    if (!dialogDictionary)
        return;
    
    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = [dialogDictionary objectForKey:@"Arabic"];

    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:28];
    dialogLabel.text = text;

    NSTimeInterval dialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:mainSpeaker.name suffix:@"English"];
    dialogLabel.alpha = .99;
    [UIView animateWithDuration: dialogDuration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         dialogLabel.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                         dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:28];
                         dialogLabel.text = arabicText;
                         dialogLabel.alpha = .99;
                         NSTimeInterval dialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:mainSpeaker.name suffix:@"Arabic"];
                         
                         [UIView animateWithDuration: dialogDuration
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
