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


@interface LetterGameViewController () {
    CGSize screenBounds;
    
    
    
    NSArray* speakerArray;
    Speaker* currentSpeaker;
    NSUInteger currentSpeakerIndex;
    SpeakerImageView* speakerImageView;
    NSMutableArray* letterImageViewArray;
    NSMutableArray* slotsImageViewArray;
    
    UIImageView* starsImageView;
}


@end

@implementation LetterGameViewController

#pragma mark Setup
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
}


 -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [super.audioManager prepareAudioWithPath:@"Resource/talking.mp3" ];
    [super.audioManager prepareAudioWithPath:@"Resource/pencil.mp3"];
    [super.audioManager prepareAudioWithPath:@"Resource/slot_correct.mp3"];
    [super.audioManager prepareAudioWithPath:@"Resource/slot_wrong.mp3"];

    screenBounds = CGSizeMake(480,320);

    UIImageView* screenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/bg.png"]];
    screenBackground.frame = CGRectMake(0,0,screenBounds.width,screenBounds.height);

    [self.view addSubview:screenBackground];
    [self.view sendSubviewToBack:screenBackground];
    
    starsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/fairy_dust.png"]];
    [self.view addSubview:starsImageView];
    starsImageView.hidden = YES;

    
    speakerArray = [SpeakerList sharedInstance].speakerArray;
    
    currentSpeakerIndex = 0;
    currentSpeaker = [[SpeakerList sharedInstance].speakerArray objectAtIndex:currentSpeaker];
    
    [self startLevel];
    
    if (DEBUG_DRAW_BORDERS) {
        [self.view drawBorderOnSubviews];
    }
    
    if (DEBUG_DRAW_SIZES) {
        [self.view drawSizeLabelOnSubviews];
    }
}


- (void)reloadGameArea {
    //actorContainerView.hidden = NO;
   
    
    [[arabicNameView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    arabicNameView.alpha = 1;
    
    
    for (ArabicLetterImageView* imageView in letterImageViewArray) {
        [imageView removeFromSuperview];
    }
    
    speakerImageView = [[SpeakerImageView alloc] initWithFrame:CGRectMake(16, 94, 140, 216) speaker:currentSpeaker];
    [self.view addSubview:speakerImageView];
    [speakerImageView animateWithDefaultAnimation];

    
    NSUInteger numberOfLetters = [currentSpeaker.letterIndexArray count];
    letterImageViewArray = [NSMutableArray arrayWithCapacity:numberOfLetters];
    slotsImageViewArray = [NSMutableArray arrayWithCapacity:numberOfLetters];

    
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
    
    gameProgressView.hidden = YES;
    
}   

#pragma mark GAME PHASES
- (void)startLevel {
   

    [self reloadGameArea];

   
    [self startShufflePhase];


}

- (void)startShufflePhase {
    
    /*
    [self animateSpeakerSuccessWithCompletion:^() {
        
        UIImageView* circleImageView = [gameProgressView circleImageViewWithIndex:currentSpeakerIndex];
        circleImageView.image = speakerImageView.image;
        [speakerImageView removeFromSuperview];
        
        if ([[SpeakerList sharedInstance] isLastSpeaker:currentSpeaker]) {
            [self performSegueWithIdentifier:@"SurpriseSegue" sender:self];
        }
        else {
            currentSpeakerIndex++;
            currentSpeaker = [[SpeakerList sharedInstance].speakerArray objectAtIndex:currentSpeakerIndex];
            [self startRound];
        }
        
    }];
    */
    
    
    
    [self displayDialogTextWithKey:@"Name" completion:^() {
        
        [self displayDialogTextWithKey:@"Like" completion:^() {
            
            [self spellArabicNameWithCompletion:^() {
                
                [self animateType:SHUFFLE duration:3 completion:^() {
                    
                    [self mixUpLettersWithCompletion: ^() {
                        
                        [self displayDialogTextWithKey:@"Shuffle" completion:^() {
                            
                            [self displayDialogTextWithKey:@"Try" completion:^() {
                                
                            }];
                            
                        }];
                        
                    }];
                    
                }];
                                
            }];
            
        }];
        
    }];
}

- (void)startSuccessPhase {
    
    [self animateType:BRAVO duration:1 completion:^() {
        
        [self displayDialogTextWithKey:@"Excellent" completion:^() {
            
            [self animateSuccessWithCompletion:^() {
            
                [self displayDialogTextWithKey:@"Later" completion:^() {
                    
                    [self animateSpeakerSuccessWithCompletion:^() {
                        
                        UIImageView* circleImageView = [gameProgressView circleImageViewWithIndex:currentSpeakerIndex];
                        circleImageView.image = speakerImageView.image;
                        [speakerImageView removeFromSuperview];
                        
                        if ([[SpeakerList sharedInstance] isLastSpeaker:currentSpeaker]) {
                            
                            [self performSegueWithIdentifier:@"SurpriseSegue" sender:self];
                        }
                        else {
                            currentSpeakerIndex++;
                            currentSpeaker = [[SpeakerList sharedInstance].speakerArray objectAtIndex:currentSpeakerIndex];
                            [self startLevel];
                        }
                        
                    }];
                    
                    
                }];
                
            }];
            
        }];
                    
    }];
    
}


#pragma mark Game Mechanics
- (void)playSpeakerDialogAudioWithKey:(NSString*)key {
    
    NSString* path = [NSString stringWithFormat:@"%@/%@.mp3",currentSpeaker.name,key];
    [super.audioManager prepareAudioWithPath:path];
    [super.audioManager playAudio:path volume:.02];
}

- (void)displayDialogTextWithKey:(NSString*)key completion:(void(^)())completion {

    NSDictionary* dialogDictionary = [currentSpeaker dialogForKey:key];
    if (!dialogDictionary)
        return;
    
    NSTimeInterval duration = [[dialogDictionary objectForKey:@"Duration"] floatValue];

    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = nil;
    
    if ([dialogDictionary count]>1) {
        arabicText = [[currentSpeaker dialogForKey:key] objectForKey:@"Arabic"];
    }
    
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:28];
    dialogLabel.text = text;
    [speakerImageView animateWithType:TALK duration:duration*2];
    //[self playSpeakerDialogAudioWithKey:key];
    [super.audioManager playAudio:@"Resource/talking.mp3" volume:.02];

    
    dialogLabel.alpha = 1;
    [UIView animateWithDuration: duration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         dialogLabel.alpha = .99;
                     }
                     completion:^(BOOL finished){
                         
                         dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:28];
                         dialogLabel.text = arabicText;
                         [super.audioManager playAudio:@"Resource/talking.mp3" volume:.02];
                         dialogLabel.alpha = 1;
                         
                         [UIView animateWithDuration: duration
                                               delay: 0.0
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              
                                              dialogLabel.alpha = .99;
                                          }
                                          completion:^(BOOL finished){
                                              
                                              completion();
                                          }];
                         
                         
                     }];
    
}

- (void)spellArabicNameWithCompletion:(void(^)())completion {
    
    [super.audioManager playAudio:@"Resource/pencil.mp3" volume:.5];
    
    [self animateArabicNameImageViewWithIndex:0 limit:[currentSpeaker.letterIndexArray count]-1 completion:completion];
}

- (void)animateArabicNameImageViewWithIndex:(NSUInteger)index limit:(NSUInteger)limit completion:(void(^)())completion {
    
    if (index>limit) {
        [super.audioManager stopAudio:@"Resource/pencil.mp3"];
        completion();
        return;
    }
    
    //Arabic Writing
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"Speakers/%@/Images/letter%02d.png",currentSpeaker.name,index]];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];

    imageView.alpha = 0;
    
    CGRect imageFrame = CGRectMake(0,0,194,84);
    imageView.frame = imageFrame;
    
    [arabicNameView addSubview:imageView];
    
    //Arabic Tiles
    NSUInteger letterIndex = [[currentSpeaker.letterIndexArray objectAtIndex:index] intValue];
    ArabicLetter* letter = [[ArabicLetter alloc] initWithLetterIndex:letterIndex];
    letter.slotPosition = index;
    
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
                         
                         imageView.alpha = 1;
                         letterImageView.alpha = 1;
                         slot.alpha = .9;
                         
                     }
                     completion:^(BOOL finished){
                         [self animateArabicNameImageViewWithIndex:index+1 limit:limit completion:completion];
                     }];
    
}

- (void)animateType:(animationType)type duration:(NSTimeInterval)duration completion:(void(^)())completion {
    
    speakerImageView.alpha = .99;
    [UIView animateWithDuration: duration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         speakerImageView.alpha = 1;
                         [speakerImageView animateWithType:type duration:duration];
                     }
                     completion:^(BOOL finished){

                        completion();
                         
                     }];
}

- (void)mixUpLettersWithCompletion:(void(^)())completion {
    
    
    for (ArabicLetterImageView* imageView in letterImageViewArray) {
        CGRect r = mixedUpLettersAreaView.bounds;
        int x = arc4random() % (int)r.size.width;
        int y = arc4random() % (int)r.size.height;
        
        CGPoint randomPoint = CGPointMake(x, y);
        CGPoint convertedPoint = [self.view convertPoint:randomPoint fromView:mixedUpLettersAreaView];
        
        [UIView animateWithDuration: ANIMATION_DURATION_MIX_UP_LETTERS
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             imageView.center = convertedPoint;
                             
                         }
                         completion:^(BOOL finished){
                             if (imageView == [letterImageViewArray objectAtIndex:[letterImageViewArray count]-1]) {
                                 completion();
                             }
                         }];
        
    }
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

- (void)animateSuccessWithCompletion:(void(^)())completion {
    //CGRect startRect = CGRectMake(self.view.bounds.size.width, self.view.bounds.size/height/2, 79, 155);
    
    CGPoint startPoint = self.view.center;
    startPoint.x = self.view.right+80;
    
    starsImageView.center = startPoint;
    starsImageView.hidden = NO;
    starsImageView.alpha = .5;
    
    [UIView animateWithDuration: 1
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         starsImageView.alpha = 1;
                         starsImageView.center = self.view.center;
                         arabicNameView.alpha = 0;
                         
                         for (UIImageView* v in letterImageViewArray) {
                             v.alpha = 0;
                         }
                         
                         for (UIImageView* v in slotsImageViewArray) {
                             v.alpha = 0;
                         }
                         
                     }
                     completion:^(BOOL finished){
                         

                         [UIView animateWithDuration: 1
                                               delay: 0.0
                                             options: UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              
                                              starsImageView.alpha = 0;
                                              starsImageView.center = CGPointMake(-100,starsImageView.centerY);
                                              
                                          }
                                          completion:^(BOOL finished){
                                              starsImageView.hidden = YES;
                                              completion();
                                          }];
                         
                         
                     }];
    
    
    
}

- (void)animateSpeakerSuccessWithCompletion:(void(^)())completion {
    [speakerImageView stopDefaultAnimation];
    [speakerImageView setToLastExitImage];
    
    [self animateType:EXIT duration:3 completion:^() {
        completion();
    }];
    
    gameProgressView.hidden = NO;
    UIImageView* circleImageView = [gameProgressView circleImageViewWithIndex:currentSpeakerIndex];
    
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = 1;
    
    

    CGPoint viewOrigin = speakerImageView.center;
    CGPoint endPoint = [self.view convertPoint:circleImageView.center fromView:gameProgressView];
    endPoint.x += 10;
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL,
                          viewOrigin.x+10, viewOrigin.y-185,
                          endPoint.x-10, endPoint.y-185,
                          endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    
    [speakerImageView.layer addAnimation:pathAnimation forKey:@"curveAnimation"];

    
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
                    [self displayDialogTextWithKey:@"Again" completion:^() {
                        
                    }];
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
