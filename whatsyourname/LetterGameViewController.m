//
//  LetterGameViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/11/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "LetterGameViewController.h"
#import "SpeakerList.h"
#import "Speaker.h"
#import "SpeakerImageView.h"
#import "ArabicLetter.h"
#import "ArabicLetterImageView.h"
#import "Slot.h"
#import "SlotImageView.h"
#import "SurpriseViewController.h"
#import "ProgressCircleImageView.h"
#import "ShuffleImageView.h"
#import "StarImageView.h"

#define ARC4RANDOM_MAX  0x100000000
#define NUMBER_OF_SUCCESS_STARS 150

static NSNumber* currentSpeakerIndex;

@interface LetterGameViewController () {
    CGPoint adjustedScrollViewCenter;
    
    NSMutableDictionary* subviewOriginDictionary;
    
    UIScrollView* scrollView;
    UIImageView* screenBackground;
    
    NSArray* speakerArray;
    Speaker* currentSpeaker;

    SpeakerImageView* speakerImageView;
    NSMutableArray* letterImageViewArray;
    NSMutableArray* slotsImageViewArray;
    NSString* unicodeNameStringForSpelling;
    
    ShuffleImageView* shuffleImageView;
    UILabel* spellingArabicLetterLabel;
    
    UIImageView *finger;
    BOOL fingerDraggingHintCancelled;
    
    BOOL playedEnglishErrorAudio;
    BOOL levelRestarted; //When level is restarted make sure currentSpeakerIndex isn't incremented
    
}
@end

@implementation LetterGameViewController
#pragma mark Setup

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self startLevel];
}

- (void)dealloc {
    NSLog(@"LetterGameViewController Dealloc");
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    levelRestarted = NO;
    
    if (currentSpeakerIndex == nil) {
        currentSpeakerIndex = [NSNumber numberWithInt:0];
    }
    
    [super.audioManager prepareAudioWithPath:@"Resource/slot_correct.mp3"];
    [super.audioManager prepareAudioWithPath:@"Resource/slot_wrong.mp3"];
    [super.audioManager prepareAudioWithPath:@"Resource/stars.mp3"];
    [super.audioManager prepareAudioWithPath:@"Resource/jumping.mp3"];
    [super.audioManager prepareAudioWithPath:@"Resource/running.mp3"];
    
    //screenBounds = CGSizeMake(480,320);
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.screenBounds.width,self.screenBounds.height)];
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.userInteractionEnabled = NO;
    
    scrollView.contentSize = CGSizeMake(self.screenBounds.width,self.screenBounds.height*2);
    scrollView.contentOffset = CGPointMake(0,self.screenBounds.height);
    [self.view addSubview:scrollView];
    
    [scrollView.superview sendSubviewToBack:scrollView];
    

    
    speakerArray = [SpeakerList sharedInstance].speakerArray;
    
    //currentSpeakerIndex = 0;
    if ([currentSpeakerIndex intValue] < [SpeakerList sharedInstance].speakerArray.count) {
        currentSpeaker = [[SpeakerList sharedInstance].speakerArray objectAtIndex:[currentSpeakerIndex intValue]];
    }

    
    //add the progressview to the scrollview
    CGRect f = gameProgressView.frame;
    f.origin.y += self.screenBounds.height;
    gameProgressView.frame = f;
    [scrollView addSubview:gameProgressView];
    
    //In a reloading scenario previous levels in the progress view need to be loaded
    if ([currentSpeakerIndex intValue] > 0) {
        
        for (int i=0;i<[currentSpeakerIndex intValue] && i<[SpeakerList sharedInstance].speakerArray.count;i++) {
            Speaker* s = [[SpeakerList sharedInstance].speakerArray objectAtIndex:i];
            SpeakerImageView* speakerIV = [[SpeakerImageView alloc] initWithFrame:CGRectMake(16, self.screenBounds.height+94, 140, 216) speaker:s];
            [gameProgressView setImage:speakerIV.lastExitImage atCircleIndex:i];
        }
    }
    
    
}


- (void)reloadGameArea {
    adjustedScrollViewCenter = CGPointMake(scrollView.center.x,scrollView.center.y+self.screenBounds.height);
    
    gameProgressView.left = scrollView.right + 30;
    gameProgressView.hidden = NO;
    
    NSString* backgroundPath = [NSString stringWithFormat:@"Speakers/%@/Images/background.png",currentSpeaker.name];
    
    [screenBackground removeFromSuperview];
    screenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundPath]];
    screenBackground.frame = CGRectMake(0,0,scrollView.contentSize.width,scrollView.contentSize.height);    
    [scrollView addSubview:screenBackground];
    [scrollView sendSubviewToBack:screenBackground];
    
    speakerImageView = [[SpeakerImageView alloc] initWithFrame:CGRectMake(16, self.screenBounds.height+94, 140, 216) speaker:currentSpeaker];
    speakerImageView.hidden = YES;
    [scrollView addSubview:speakerImageView];
    speakerImageView.contentMode = UIViewContentModeBottomLeft;
    [speakerImageView repeatAnimation:DEFAULT];
    
    
    shuffleImageView = [[ShuffleImageView alloc] initWithFrame:CGRectMake(self.view.right,speakerImageView.bottom-219,183,219) speaker:currentSpeaker];
    [scrollView addSubview:shuffleImageView];
    
    
    
    //Clear arabic name spelling
    [[arabicNameView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    arabicNameView.alpha = 1;
    arabicNameView.backgroundColor = [UIColor clearColor];
    
    spellingArabicLetterLabel = [[UILabel alloc] initWithFrame:arabicNameView.bounds];
    spellingArabicLetterLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:84];
    spellingArabicLetterLabel.textColor = [UIColor blackColor];
    spellingArabicLetterLabel.backgroundColor = [UIColor clearColor];
    spellingArabicLetterLabel.textAlignment = NSTextAlignmentRight;
    //spellingArabicLetterLabel.shadowColor = [UIColor whiteColor];
    //spellingArabicLetterLabel.shadowOffset = CGSizeMake(1,1);
    spellingArabicLetterLabel.adjustsFontSizeToFitWidth = YES;
    spellingArabicLetterLabel.minimumScaleFactor = 0.5;
    [arabicNameView addSubview:spellingArabicLetterLabel];
    
    //Save subview origins to reset positions on even index speakers 0,2 etc
    
    if (!subviewOriginDictionary) {
        subviewOriginDictionary = [[NSMutableDictionary alloc] init];
        
        subviewOriginDictionary[@"speakerImageView"] = [NSValue valueWithCGPoint:speakerImageView.origin];
        subviewOriginDictionary[@"arabicNameView"] = [NSValue valueWithCGPoint:arabicNameView.origin];
        subviewOriginDictionary[@"slotContainerView"] = [NSValue valueWithCGPoint:slotContainerView.origin];
        subviewOriginDictionary[@"mixedUpLettersAreaView"] = [NSValue valueWithCGPoint:mixedUpLettersAreaView.origin];
    }
    else {
        CGRect newFrame;
        
        newFrame = speakerImageView.frame;
        newFrame.origin = [subviewOriginDictionary[@"speakerImageView"] CGPointValue];
        //newFrame.origin = [[NSValue valueWithCGPoint:speakerImageView.origin] CGPointValue];
        speakerImageView.frame = newFrame;
        
        newFrame = arabicNameView.frame;
        newFrame.origin = [subviewOriginDictionary[@"arabicNameView"] CGPointValue];
        //newFrame.origin = [[NSValue valueWithCGPoint:arabicNameView.origin] CGPointValue];
        arabicNameView.frame = newFrame;
        
        newFrame = slotContainerView.frame;
        newFrame.origin = [subviewOriginDictionary[@"slotContainerView"] CGPointValue];
        //newFrame.origin = [[NSValue valueWithCGPoint:slotContainerView.origin] CGPointValue];
        slotContainerView.frame = newFrame;
        
        newFrame = mixedUpLettersAreaView.frame;
        newFrame.origin = [subviewOriginDictionary[@"mixedUpLettersAreaView"] CGPointValue];
        //newFrame.origin = [[NSValue valueWithCGPoint:mixedUpLettersAreaView.origin] CGPointValue];
        mixedUpLettersAreaView.frame = newFrame;
    }
    
        
    //Position odd index speakers subviews to the opposite side
    if ([currentSpeakerIndex intValue] % 2==1) {
        CGRect newFrame;
        
        newFrame = speakerImageView.frame;
        newFrame.origin = CGPointMake(self.view.width-newFrame.origin.x-newFrame.size.width,newFrame.origin.y);
        speakerImageView.frame = newFrame;
        
        newFrame = arabicNameView.frame;
        newFrame.origin = CGPointMake(self.view.width-newFrame.origin.x-newFrame.size.width,newFrame.origin.y);
        arabicNameView.frame = newFrame;
        
        newFrame = slotContainerView.frame;
        newFrame.origin = CGPointMake(self.view.width-newFrame.origin.x-newFrame.size.width,newFrame.origin.y);
        slotContainerView.frame = newFrame;
        
        newFrame = mixedUpLettersAreaView.frame;
        newFrame.origin = CGPointMake(self.view.width-newFrame.origin.x-newFrame.size.width,newFrame.origin.y);
        mixedUpLettersAreaView.frame = newFrame;
        
        shuffleImageView.right = self.view.left;
        
    }

    
    
    
    
    //Setting up empty slots
    NSUInteger numberOfLetters = [currentSpeaker.letterIndexArray count];
    letterImageViewArray = [NSMutableArray arrayWithCapacity:numberOfLetters];
    slotsImageViewArray = [NSMutableArray arrayWithCapacity:numberOfLetters];
    
    for (ArabicLetterImageView* imageView in letterImageViewArray) {
        [imageView removeFromSuperview];
    }
    
    
    CGSize slotImageSize = CGSizeMake(50, 50);
    NSInteger originY = 0;
    NSInteger heightToDivideEvenly = slotContainerView.height - slotImageSize.height; //Distance of origin of lowest slot to top of container
    
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
        
        CGRect r = CGRectMake((slotContainerView.width-slotImageSize.width)-(slotImageSize.width*i), originY, slotImageSize.width, slotImageSize.height);
        Slot* s = [[Slot alloc] initWithPosition:i];
        SlotImageView* slotImageView = [[SlotImageView alloc] initWithFrame:r slot:s];
        slotImageView.alpha = 0;
        
        CGRect convertedFrame = [self.view convertRect:r fromView:slotContainerView];
        slotImageView.frame = convertedFrame;
        [self.view addSubview:slotImageView];
        
        [slotsImageViewArray addObject:slotImageView];
        //slots.alpha = 0;
    }
    
    playedEnglishErrorAudio = NO;
    [self.audioManager loadErrorAudioWithPrefix:currentSpeaker.name key:@"Again"];
}

- (IBAction)homeButtonTouched:(id)sender  {
    [super homeButtonTouched:sender];
    
    currentSpeakerIndex = [NSNumber numberWithInt:0];
}

- (IBAction)restartButtonTouched:(id)sender {
    levelRestarted = YES;
    [super restartButtonTouched:sender];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPopViewControllerNotification object:self];
}

#pragma mark Game Phases
- (void)startLevel {
    
    
    [self reloadGameArea];
    
    
    [self startShufflePhase];
    
    
}

- (void)startShufflePhase {
    
    if (SKIP_TO_BONUS_LEVEL) {
        [self performSegueWithIdentifier:@"SurpriseSegue" sender:self];return;
    }
    
    speakerImageView.hidden = NO;
    
    [self displayDialogTextWithKey:@"Name" animationType:TALK completion:^() {
        
        [self displayDialogTextWithKey:@"Like" animationType:TALK completion:^() {
            
            [self spellArabicNameWithCompletion:^() {
                
                [self showSpeakerShuffleAnimationWithCompletion:^() {//Nolia Bubble
                    
                    [self mixUpLettersWithCompletion: ^() {
                        
                        if (!shuffleImageView.animationFound) {
                            [self displayDialogTextWithKey:@"Shuffle" animationType:TALK completion:^() {//Nolia Running
                                
                                [self displayDialogTextWithKey:@"Try" animationType:TALK completion:^() {
                                    [self animateFingerDraggingHint];
                                                                        
                                }];
                                
                            }];
                        }
                        else {
                            [self displayDialogTextWithKey:@"Try" animationType:TALK completion:^() {
                                
                            }];                            
                        }
                        
                        
                    }];
                    
                }];
                
            }];
            
        }];
        
    }];
}

- (void)startSuccessPhase {
    
    //[self animateType:BRAVO repeatingDuration:5 keepLastFrame:YES completion:^() {
    //}];
    
    [self displayDialogTextWithKey:@"Excellent" animationType:BRAVO completion:^() {
        
        [self animateLevelSuccessWithCompletion:^() {
            
            [self displayDialogTextWithKey:@"Later" animationType:TALK completion:^() {
                
                [self animateSpeakerSuccessWithCompletion:^() {
                    
                    [self animateProgressViewPhase1WithCompletion:^() {
                        
                        [self animateProgressViewPhase2WithCompletion:^() {
                            
                            if (!levelRestarted) {
                                if ([[SpeakerList sharedInstance] isLastSpeaker:currentSpeaker]) {
                                    currentSpeakerIndex = [NSNumber numberWithInt:0];
                                    [self performSegueWithIdentifier:@"SurpriseSegue" sender:self];
                                }
                                else {
                                    int addSpeakerIndex = [currentSpeakerIndex intValue] + 1;
                                    currentSpeakerIndex = [NSNumber numberWithInt:addSpeakerIndex];
                                    if (currentSpeakerIndex.intValue < [SpeakerList sharedInstance].speakerArray.count) {
                                        currentSpeaker = [[SpeakerList sharedInstance].speakerArray objectAtIndex:[currentSpeakerIndex intValue]];
                                        [self startLevel];
                                    }
                                    else {
                                        currentSpeakerIndex = [NSNumber numberWithInt:0];
                                    }
                                }
                            }
                            
                        }];
                        
                    }];
                    
                }];
                
            }];
            
        }];
        
    }];
    
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
    
    if ([key isEqualToString:@"Excellent"] || [key isEqualToString:@"Shuffle"]) {
        [speakerImageView animateWithType:animationType repeatingDuration:dialogDuration keepLastFrame:YES];
    }
    else {
        [speakerImageView animateWithType:animationType repeatingDuration:dialogDuration];
    }
    
    
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(englishDialogDuration), dispatch_get_main_queue(), ^{
       
        dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:dialogLabel.font.pointSize];
        dialogLabel.text = arabicText;
        [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:currentSpeaker.name suffix:@"Arabic"];
        
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(arabicDialogDuration), dispatch_get_main_queue(), ^{
            completion();
        });
        
        
    });
    
         
}

- (void)animateSpeakerWithType:(AnimationType)type repeatingDuration:(NSTimeInterval)repeatingDuration keepLastFrame:(BOOL)keepLastFrame completion:(void(^)())completion {
    

    [speakerImageView animateWithType:type repeatingDuration:repeatingDuration keepLastFrame:keepLastFrame];
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(repeatingDuration), dispatch_get_main_queue(), ^{
        
       completion();
    });
    
}

- (void)animateSpeakerWithType:(AnimationType)type repeatingDuration:(NSTimeInterval)repeatingDuration completion:(void(^)())completion {
    
    [self animateSpeakerWithType:type repeatingDuration:repeatingDuration keepLastFrame:NO completion:completion];
    
}

- (void)animateImageView:(UIImageView*)imageView toPoint:(CGPoint)point {
    
    if ([imageView isKindOfClass:[ArabicLetterImageView class]]) {
        ArabicLetterImageView* letter = (ArabicLetterImageView*)imageView;
        letter.isAnimating = YES;
    }
    
    [UIView animateWithDuration: ANIMATION_DURATION_SLIDE_TO_SLOT
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         imageView.center = point;
                         
                     }
                     completion:^(BOOL finished){
                         
                         if ([imageView isKindOfClass:[ArabicLetterImageView class]]) {
                             ArabicLetterImageView* letter = (ArabicLetterImageView*)imageView;
                             letter.isAnimating = NO;
                         }
                         
                     }];
}

#pragma mark Shuffle Methods
- (void)spellArabicNameWithCompletion:(void(^)())completion {
    
    //Calculate size of entire unicdoe name to size the label
    NSString *arabicUnicode = [currentSpeaker unicodeName];
    spellingArabicLetterLabel.text = arabicUnicode;
    [spellingArabicLetterLabel sizeToFit];
    spellingArabicLetterLabel.text = @"";
    spellingArabicLetterLabel.center = CGPointMake(spellingArabicLetterLabel.superview.width/2,spellingArabicLetterLabel.superview.height/2);
    
    
    NSTimeInterval dialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:@"Spell" prefix:currentSpeaker.name suffix:@"Arabic"];
    [speakerImageView animateWithType:TALK repeatingDuration:dialogDuration];
    
    unicodeNameStringForSpelling = [Speaker uniCodeNameWithLetterIndexArray:currentSpeaker.letterIndexArray];
    [self animateArabicNameImageViewWithIndex:0 limit:[currentSpeaker.letterIndexArray count]-1 completion:completion];
}

- (void)animateArabicNameImageViewWithIndex:(NSUInteger)index limit:(NSUInteger)limit completion:(void(^)())completion {
    
    if (index>limit) {
        completion();
        return;
    }
    
    NSUInteger letterIndex = [[currentSpeaker.letterIndexArray objectAtIndex:index] intValue];
    ArabicLetter* letter = [[ArabicLetter alloc] initWithLetterIndex:letterIndex];
    letter.slotPosition = index;
    unichar unicodeChar = [unicodeNameStringForSpelling characterAtIndex:index];

    
    spellingArabicLetterLabel.text = [NSString stringWithFormat:@"%@%C",spellingArabicLetterLabel.text,unicodeChar];
    

    //Spell out each letter in dialog label
    if (index==0) dialogLabel.text = @"";
    dialogLabel.text = [NSString stringWithFormat:@"%@%C",dialogLabel.text,letter.unicodeGeneral];
    
    
    ArabicLetterImageView* letterImageView = [[ArabicLetterImageView alloc] initWithArabicLetter:letter];
    letterImageView.alpha = 0;
    
    //Slots
    SlotImageView* slot = [slotsImageViewArray objectAtIndex:letter.slotPosition];
    slot.alpha = 0;
    
    letterImageView.frame = slot.frame;
    [self.view addSubview:letterImageView];
    [letterImageViewArray addObject:letterImageView];
    
    
    [UIView animateWithDuration: ANIMATION_DURATION_ARABIC_SPELL
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         //imageView.alpha = 1;
                         
                         letterImageView.alpha = 1;
                         slot.alpha = .9;
                         
                     }
                     completion:^(BOOL finished){
                         [self animateArabicNameImageViewWithIndex:index+1 limit:limit completion:completion];
                     }];
    
}

- (void)showSpeakerShuffleAnimationWithCompletion:(void(^)())completion  {
    
    
    if (!shuffleImageView.animationFound) { //Nolia Running Animation
        NSTimeInterval shuffleSoundEffectDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:@"ShuffleSoundEffect" prefix:currentSpeaker.name suffix:@""];
        [self animateSpeakerWithType:SHUFFLE repeatingDuration:shuffleSoundEffectDuration keepLastFrame:NO completion:^() {
            
            completion();
            
        }];
    }
    else {
        completion();
    }
}

- (void)mixUpLettersWithCompletion:(void(^)())completion {
    
    NSTimeInterval shuffleDuration = 2;
    float letterFallDownAnimationDelay = 0;
    
    if (shuffleImageView.animationFound)
    {
        letterFallDownAnimationDelay = 0.40;
        [super.audioManager playAudio:@"Resource/running.mp3" volume:1];
        [self displayDialogTextWithKey:@"Shuffle" animationType:SHUFFLE completion:^(){
            completion();
        }];
        
        //Nolia runnign across screen
        [shuffleImageView animateWithDuration:shuffleDuration];
        [UIView animateWithDuration: 1
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             CGPoint startPoint = shuffleImageView.origin;
                             CGPoint endPoint;
                             endPoint.y = startPoint.y;
                             
                             if (startPoint.x >= self.screenBounds.width) {
                                 endPoint.x = 0-shuffleImageView.width;
                             }
                             else {
                                 endPoint.x = self.screenBounds.width;
                             }
                             
                             shuffleImageView.origin = endPoint;
                             
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }

    //Letters falling out of slots
    for (ArabicLetterImageView* imageView in letterImageViewArray) {
        CGRect r = mixedUpLettersAreaView.bounds;
        int x = arc4random() % (int)r.size.width;
        int y = arc4random() % (int)r.size.height;
        
        CGPoint randomPoint = CGPointMake(x, y);
        CGPoint convertedPoint = [self.view convertPoint:randomPoint fromView:mixedUpLettersAreaView];
        
        [UIView animateWithDuration: shuffleDuration
                              delay: letterFallDownAnimationDelay
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             imageView.center = convertedPoint;
                             
                         }
                         completion:^(BOOL finished){
                             if (!shuffleImageView.animationFound && imageView == [letterImageViewArray lastObject]) {
                                 completion();
                             }
                             
                             //}
                         }];
        
    }
}

- (void)animateFingerDraggingHint {
    ArabicLetterImageView* arabicLetterimageView = [letterImageViewArray objectAtIndex:0];
    SlotImageView* slotImageView = [slotsImageViewArray objectAtIndex:0];
    
    if (!finger) {
        finger = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/finger.png"]];
        finger.frame = CGRectMake(0,0,35,50);
        [arabicLetterimageView.superview addSubview:finger];

    }
    
    finger.center = CGPointMake(arabicLetterimageView.center.x,arabicLetterimageView.center.y+(arabicLetterimageView.height/2));
    
    [UIView animateWithDuration: 1.5
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         finger.center = CGPointMake(slotImageView.center.x,slotImageView.center.y+(slotImageView.height/2));
                     }
                     completion:^(BOOL finished){
                         if (!fingerDraggingHintCancelled) {
                             [self animateFingerDraggingHint];
                         }

                     }];
}

#pragma mark Success Methods

- (void)addStarWithCompletion:(void(^)())completion {
    
    
    int randomX = (arc4random() % 10)-5;
    int randomY = (arc4random() % 10)-5;
    StarImageView* star = [[StarImageView alloc] initWithFrame:CGRectMake(arabicNameView.center.x + randomX,arabicNameView.bottom + randomY,25,25)];
    
    
    
    CGPoint endPoint = CGPointZero;
    
    int randomSide = arc4random() % 4;
    
    switch (randomSide) {
        case 0:
            endPoint.x = 0;
            endPoint.y = arc4random() % (int)self.screenBounds.height;
            break;
        case 1:
            endPoint.x = self.screenBounds.width;
            endPoint.y = arc4random() % (int)self.screenBounds.height;
            break;
        case 2:
            endPoint.x = arc4random() % (int)self.screenBounds.width;
            endPoint.y = 0;
            break;
        case 3:
            endPoint.x = arc4random() % (int)self.screenBounds.height;
            endPoint.y = self.screenBounds.height;
            break;
            
        default:
            break;
    }
    
    [self.view addSubview:star];
    [star animateWithEndPoint:(CGPoint)endPoint completion:^() {
        
        completion();
        
        //NSLog(@"%d",starCount);
        
    }];
    
}

- (void)animateLevelSuccessWithCompletion:(void(^)())completion {
    [speakerImageView animateWithType:DEFAULT repeatingDuration:3];
    
    [super.audioManager playAudio:@"Resource/stars.mp3" volume:1];
    for (int index=0;index<NUMBER_OF_SUCCESS_STARS;index++) {
        
        float randomDuration;
        if (index==0) {
            randomDuration = ((float)arc4random()/ARC4RANDOM_MAX)*3;
        }
        else if (index%5==0) {
            randomDuration = ((float)arc4random()/ARC4RANDOM_MAX)*3;
        }
        
        
        if (index==NUMBER_OF_SUCCESS_STARS-1) {
            [self performSelector:@selector(addStarWithCompletion:) withObject:completion afterDelay:randomDuration];
        }
        else {
            [self performSelector:@selector(addStarWithCompletion:) withObject:^(){} afterDelay:randomDuration];
        }
        
    }

    
    [UIView animateWithDuration: 4
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         arabicNameView.alpha = 0;
                         
                         for (UIImageView* v in letterImageViewArray) {
                             v.alpha = 0;
                         }
                         
                         for (UIImageView* v in slotsImageViewArray) {
                             v.alpha = 0;
                         }
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
        
}

- (void)animateProgressViewPhase1WithCompletion:(void(^)())completion {
    
    [gameProgressView setCurrentLevelCircleIndex:[currentSpeakerIndex intValue]];
    [UIView animateWithDuration: 2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         [gameProgressView startRotations];
                         
                         //Move the current level circle to the same coordinates as the speaker image view
                         ProgressCircleImageView* circle = [gameProgressView circleImageViewWithIndex:[currentSpeakerIndex intValue]];
                         gameProgressView.left = adjustedScrollViewCenter.x - circle.origin.x - (circle.width/2);
                         
                     }
                     completion:^(BOOL finished){
                         
                         completion();
                     }];
    
}

- (void)animateProgressViewPhase2WithCompletion:(void(^)())completion {
    [speakerImageView removeFromSuperview];
    //ProgressCircleImageView* circleImageView = [gameProgressView circleImageViewWithIndex:[currentSpeakerIndex intValue]];
    //circleImageView.contentMode = UIViewContentModeCenter;
    [gameProgressView setImage:speakerImageView.lastExitImage atCircleIndex:[currentSpeakerIndex intValue]];
    
    [UIView animateWithDuration: 2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         gameProgressView.left = 46;
                         
                     }
                     completion:^(BOOL finished){
                         [gameProgressView stopRotations];
                         
                         
                         
                         dispatch_after(DISPATCH_SECONDS_FROM_NOW(0.25), dispatch_get_main_queue(), ^{
                             
                             completion();
                         });

                     }];
    
    
}

- (void)animateSpeakerSuccessWithCompletion:(void(^)())completion {
    [speakerImageView stopRepeatingAnimations];
    [speakerImageView setToLastExitImage];
    
    //[scrollView drawBorderOnSubviews];
    speakerImageView.contentMode = UIViewContentModeCenter;
    
    //[self animateType:EXIT repeatingDuration:3 completion:^() {
        
    //}];
    [speakerImageView animateWithType:EXIT repeatingDuration:0 keepLastFrame:NO];
    [super.audioManager playAudio:@"Resource/jumping.mp3" volume:1];
    NSTimeInterval animationDuration = [speakerImageView animationDurationOfType:EXIT];
    //UIImageView* circleImageView = [gameProgressView circleImageViewWithIndex:currentSpeakerIndex];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = animationDuration;//1.8;
    //pathAnimation.delegate = self;
    
    CGPoint viewOrigin = speakerImageView.center;
    CGPoint endPoint = adjustedScrollViewCenter;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL,
                          viewOrigin.x+10, viewOrigin.y-500,
                          endPoint.x-10, endPoint.y-500,
                          endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    [speakerImageView.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
    
    [UIView animateWithDuration: pathAnimation.duration/2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGPoint p = scrollView.contentOffset;
                         p.y = 0;
                         scrollView.contentOffset = p;
                         
                     }
                     completion:^(BOOL finished){
                         
                         UIImageView* circle_empty = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/progress_circle_empty.png"]];
                         circle_empty.center = endPoint;
                         [scrollView addSubview:circle_empty];
                         
                         [UIView animateWithDuration: pathAnimation.duration/2
                                               delay: 0.0
                                             options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              
                                              CGPoint p = scrollView.contentOffset;
                                              p.y = self.screenBounds.height;
                                              scrollView.contentOffset = p;
                                              
                                          }
                                          completion:^(BOOL finished){
                                              [speakerImageView setToLastExitImage];
                                              [circle_empty removeFromSuperview];
                                              completion();
                                              
                                          }];
                         
                     }];
    
    
    
}

#pragma mark Game Slot Mechanics
- (BOOL)isCorrectSlot:(SlotImageView*)slotImageView forLetterImageView:(ArabicLetterImageView*)letterImageView {
    
    
    if (slotImageView.slot.position == letterImageView.arabicLetter.slotPosition) {
        return YES;
    }
    
    return NO;
}

- (SlotImageView*)slotThatIntersectsArabicLetterImageView:(ArabicLetterImageView*)letterImageView {
    
    for (SlotImageView* slotImageView in slotsImageViewArray) {
        
        if (!slotImageView.slot.isFilled && CGRectIntersectsRect(slotImageView.frame, letterImageView.frame)) {
            return slotImageView;
        }
        
    }
    
    
    return nil;
}

//When detecting if a letter is in the wrong spot, give more frame buffer on failures so that there are less false positives. Essentially making it harder
//to fail and animate the letter back to the starting position
- (BOOL)isFailureIntersectCheckForSlotImageView:(SlotImageView*)slotImageView arabicLetterImageView:(ArabicLetterImageView*)arabicLetterImageView {
    CGRect slotFrame = slotImageView.frame;
    CGRect letterFrame = arabicLetterImageView.frame;
    
    slotFrame = CGRectInset(slotFrame, slotFrame.size.width*SLOT_FRAME_INSET_FOR_FAILURE, slotFrame.size.height*SLOT_FRAME_INSET_FOR_FAILURE);
    
    if (CGRectIntersectsRect(slotFrame, letterFrame)) {
        return YES;
    }
    return NO;
}

- (BOOL)allArabicLettersAreInCorrectSlot {
    
    for (ArabicLetterImageView* imageView in letterImageViewArray) {
        if (!imageView.arabicLetter.isInCorrectSlot) {
            return NO;
        }
    }
    return YES;
}

- (void)playErrorAudioWithKey:(NSString*)key animationType:(AnimationType)animationType completion:(void(^)())completion {
    NSDictionary* dialogDictionary = [currentSpeaker dialogForKey:key];
    if (!dialogDictionary)
        return;
    
    
    //NSTimeInterval englishDialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:currentSpeaker.name suffix:@"English"];
    //NSTimeInterval arabicDialogDuration = [self getDurationDialogAudioWithKey:key prefix:currentSpeaker.name suffix:@"Arabic"];
    //NSTimeInterval dialogDuration = englishDialogDuration + arabicDialogDuration;
    
    NSTimeInterval audioDuration = [self.audioManager playErrorAudio];
    [speakerImageView animateWithType:animationType repeatingDuration:audioDuration];
    
    
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(2), dispatch_get_main_queue(), ^{
        
        completion();
    });

}


#pragma mark Touches
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    ArabicLetterImageView* objectToDrag = (ArabicLetterImageView*)touch.view;
    
    if ([objectToDrag isKindOfClass:[ArabicLetterImageView class]] && objectToDrag.dragStartPoint.x != 0 && objectToDrag.dragStartPoint.y != 0  && !objectToDrag.arabicLetter.isInCorrectSlot && !objectToDrag.isAnimating)
    {
        
        objectToDrag.center = location;
        
        SlotImageView* slotImageView = [self slotThatIntersectsArabicLetterImageView:objectToDrag];
        
        if (slotImageView && [self isCorrectSlot:slotImageView forLetterImageView:objectToDrag]) {
            [super.audioManager playAudio:@"Resource/slot_correct.mp3" volume:1];
            [self animateImageView:objectToDrag toPoint:slotImageView.center];
            
            objectToDrag.arabicLetter.isInCorrectSlot = YES;
            slotImageView.slot.arabicLetter = objectToDrag.arabicLetter;
            
            
            if ([self allArabicLettersAreInCorrectSlot]) {
                [self startSuccessPhase];
            }
            
        }
        else if (slotImageView && !slotImageView.slot.isFilled) {
            if (objectToDrag.dragStartPoint.x != 0 && objectToDrag.dragStartPoint.y !=0) {
                
                if ([self isFailureIntersectCheckForSlotImageView:slotImageView arabicLetterImageView:objectToDrag]) {
                    
                    if (!playedEnglishErrorAudio || !self.audioManager.hasErrorAudio) {
                        [self displayDialogTextWithKey:@"Again" animationType:TALK completion:^() {}];
                        playedEnglishErrorAudio = YES;
                    }
                    else {
                        [self playErrorAudioWithKey:@"Again" animationType:TALK completion:^() {}];
                    }
                    
                    
                    [super.audioManager playAudio:@"Resource/slot_wrong.mp3" volume:1];
                    [self animateImageView:objectToDrag toPoint:objectToDrag.dragStartPoint];
                    objectToDrag.dragStartPoint = CGPointZero;
                }
                
            }
        }
    }
    
    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    
    if (finger.superview) {
        fingerDraggingHintCancelled = YES;
        [finger removeFromSuperview];
    }
    
    
    ArabicLetterImageView* objectToDrag = (ArabicLetterImageView*)touch.view;
    
    if ([objectToDrag isKindOfClass:[ArabicLetterImageView class]])
    {
        //Don't save the dragstartpoint when the letter is already on top of a slot to prevent false positives
        //SlotImageView* slotImageView = [self slotThatIntersectsArabicLetterImageView:objectToDrag];
        //if (!slotImageView) {
        objectToDrag.dragStartPoint = location;
        //}
        [self.view bringSubviewToFront:objectToDrag];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end