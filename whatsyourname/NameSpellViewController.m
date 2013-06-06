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

@interface NameSpellViewController () {
    NSDictionary* yourNameDialogDictionary;
    
    NSArray* letters;
    NSMutableArray* letterImageViewArray;
}

@end

@implementation NameSpellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"YourNameDialog"] ofType:@"plist"];
    
    yourNameDialogDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    
    background.image = [UIImage imageNamed:@"Resource/background.png"];
    background.contentMode = UIViewContentModeBottomLeft;
    //background.frame = CGRectMake(0,0,screenBounds.width,screenBounds.height);
    [self.view sendSubviewToBack:background];
    
    letters = @[@10,@22,@25,@26,@27];

    [self createLetterImageViewArray];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self displayDialogTextWithKey:@"LikeThis" completion:^() {
        
        [self animateArabicNameImageViewWithIndex:0 limit:letters.count-1 completion:^() {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
    }];
    
}

- (void)createLetterImageViewArray {
    NSUInteger numberOfLetters = letters.count;
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
        ArabicLetter* l = [[ArabicLetter alloc] initWithLetterIndex:[letters[i] intValue]];
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
    
    //Arabic Writing
    //UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"Speakers/%@/Images/letter%02d.png",currentSpeaker.name,index]];
    //UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    //imageView.alpha = 0;
    
    //CGRect imageFrame = CGRectMake((arabicNameView.width/2)-(194/2),0,194,84);
    //imageView.frame = imageFrame;
    
    //[arabicNameView addSubview:imageView];
    
    //Arabic Tiles
    NSUInteger letterIndex = [[letters objectAtIndex:index] intValue];
    ArabicLetter* letter = [[ArabicLetter alloc] initWithLetterIndex:letterIndex];
    letter.slotPosition = index;
    
    ArabicLetterImageView* letterImageView = letterImageViewArray[index];
    
    
    //Spell out each letter in dialog label
    if (index==0) arabicSpellLabel.text = @"";
    arabicSpellLabel.text = [NSString stringWithFormat:@"%@%C",arabicSpellLabel.text,letter.unicode];
        
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
    
    NSTimeInterval duration = [[dialogDictionary objectForKey:@"Duration"] floatValue];
    
    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = [dialogDictionary objectForKey:@"Arabic"];
    
    [self displayEnglishText:text arabicText:arabicText key:(NSString*)key duration:duration completion:completion];
}


- (void)displayEnglishText:(NSString*)englishText arabicText:(NSString*)arabicText key:(NSString*)key duration:(NSTimeInterval)duration completion:(void(^)())completion {
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:28];
    dialogLabel.text = englishText;
    
    //[mainSpeakerImageView animateWithType:TALK duration:duration*2];
    //[self playSpeakerDialogAudioWithKey:key suffix:@"English"];
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
                         //[self playSpeakerDialogAudioWithKey:key suffix:@"Arabic"];
                         
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
