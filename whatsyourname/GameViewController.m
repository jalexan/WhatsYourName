//
//  ViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/11/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "GameViewController.h"
#import "UIView+Additions.h"
#import "SpeakerList.h"
#import "Speaker.h"
#import "SpeakerImageView.h"
#import "ArabicLetter.h"
#import "ArabicLetterImageView.h"
#import "Slot.h"
#import "SlotImageView.h"
#import "SurpriseViewController.h"


#define DEBUG1 1

#if DEBUG1
    #define ANIMATION_DURATION_ARABIC_SPELL 0
    #define ANIMATION_DURATION_MIX_UP_LETTERS .5
    #define ANIMATION_DURATION_SLIDE_TO_SLOT 0.2
#else
    #define ANIMATION_DURATION_ARABIC_SPELL 1.5
    #define ANIMATION_DURATION_MIX_UP_LETTERS 1
    #define ANIMATION_DURATION_SLIDE_TO_SLOT 0.2
#endif



@interface GameViewController () {
    CGSize screenBounds;
    
    NSArray* speakerArray;
    Speaker* currentSpeaker;
    NSUInteger currentSpeakerIndex;
    SpeakerImageView* speakerImageView;
    NSMutableArray* letterImageViewArray;
    NSMutableArray* slotsImageViewArray;
    
    NSMutableDictionary* audioNameToPlayer;
    UIImageView* starsImageView;
    //BOOL alwaysPlayAudioEffects;
    //UInt32 otherAudioIsPlaying;
}

@end

@implementation GameViewController

#pragma mark Setup
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGRect tempBounds = [[UIScreen mainScreen] bounds];
    if (tempBounds.size.height==568 || tempBounds.size.width==568) {
        CGRect r = self.view.frame;
        r.size = CGSizeMake(320, 480);
        r.origin = CGPointMake(0, 44);
        self.view.frame = r;
    }


    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleAudioInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: [AVAudioSession sharedInstance]];
    
    [self prepareAudio:@"pencil"];
    //alwaysPlayAudioEffects = YES;
    //otherAudioIsPlaying = 0;
	
    screenBounds = CGSizeMake(480,320);

    UIImageView* screenBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/bg.jpg"]];
    screenBackground.frame = CGRectMake(0,0,screenBounds.width,screenBounds.height);
    screenBackground.alpha = 0.8;
    [self.view addSubview:screenBackground];
    [self.view sendSubviewToBack:screenBackground];
    
    starsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/fairy_dust.png"]];
    [self.view addSubview:starsImageView];
    starsImageView.hidden = YES;

    
    speakerArray = [SpeakerList sharedInstance].speakerArray;
    
    currentSpeakerIndex = 0;
    currentSpeaker = [[SpeakerList sharedInstance].speakerArray objectAtIndex:currentSpeaker];
    
    [self startRound];
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
    
    for (int i=0;i<numberOfLetters;i++) {
        Slot* s = [[Slot alloc] initWithPosition:i];
        
        CGRect r = CGRectMake((slotContainerView.width-40)-(40*i), 0, 40, 40);
        
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
- (void)startRound {


    [self reloadGameArea];

   
    [self startShufflePhase];


}

- (void)startShufflePhase {
    //[self animateSpeakerSuccessWithCompletion:^() {
        
    //}];
    //return;
    
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
                            [self startRound];
                        }
                        
                    }];
                    
                    
                }];
                
            }];
            
        }];
                    
    }];
    
}


#pragma mark Game Mechanics
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

    dialogLabel.alpha = 1;
    [speakerImageView animateWithType:TALK duration:duration];
    
    [UIView animateWithDuration: duration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{                         
                         dialogLabel.alpha = .99;
                     }
                     completion:^(BOOL finished){
                         
                         dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:28];
                         dialogLabel.text = arabicText;
                         dialogLabel.alpha = 1;
                         [speakerImageView animateWithType:TALK duration:duration];
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
    
    [self playAudio:@"pencil"];
    
    [self animateArabicNameImageViewWithIndex:0 limit:[currentSpeaker.letterIndexArray count]-1 completion:completion];
}

- (void)animateArabicNameImageViewWithIndex:(NSUInteger)index limit:(NSUInteger)limit completion:(void(^)())completion {
    
    if (index>limit) {
        [self stopAudio:@"pencil"];
        completion();
        return;
    }
    
    //Arabic Writing
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"Speakers/%@/Images/letter%02d.png",currentSpeaker.name,index]];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];

    imageView.alpha = 0;
    
    CGRect imageFrame;
    imageFrame.size.width = image.size.width*.4;
    imageFrame.size.height = image.size.height*.4;
    imageFrame.origin.x = arabicNameView.frame.size.width - imageFrame.size.width;
    imageFrame.origin.y = 0;
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
                         slot.alpha = 1;
                         
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

        if (CGRectIntersectsRect(slotImageView.frame, letterImageView.frame) && !slotImageView.slot.isFilled) {
            return slotImageView;
        }
        
    }
    
    
    return nil;
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
            
            [self animateImageView:objectToDrag toPoint:slotImageView.center];

            objectToDrag.arabicLetter.isInCorrectSlot = YES;
            slotImageView.slot.arabicLetter = objectToDrag.arabicLetter;
            
            
            if ([self allArabicLettersAreInCorrectSlot]) {
                [self startSuccessPhase];
            }
            
        }
        else if (slotImageView && !slotImageView.slot.isFilled) {
            if (objectToDrag.dragStartPoint.x != 0 && objectToDrag.dragStartPoint.y !=0) {
                
                [self displayDialogTextWithKey:@"Again" completion:^() {
                    
                }];
                
                [self animateImageView:objectToDrag toPoint:objectToDrag.dragStartPoint];
                objectToDrag.dragStartPoint = CGPointZero;
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
        objectToDrag.dragStartPoint = location;
        [self.view bringSubviewToFront:objectToDrag];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}

#pragma mark Audio
- (void)initializeAudio {
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    if (session) {
        [session setCategory: AVAudioSessionCategoryAmbient error: nil];
        UInt32 otherAudioIsPlayingVal;
        UInt32 propertySize = sizeof (otherAudioIsPlayingVal);
        AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying,
                                 &propertySize,
                                 &otherAudioIsPlayingVal
                                 );
    }
    //UInt32 otherAudioIsPlaying = (BOOL)otherAudioIsPlayingVal;
    //if (otherAudioIsPlaying){
    //    [backgroundPlayer pause];
    //} else {
    //    [backgroundPlayer play];
   // }
}

- (AVAudioPlayer*)prepareAudio:(NSString*)audioName {
    if (audioNameToPlayer == nil){
        audioNameToPlayer = [NSMutableDictionary new];
    }
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Resource/%@",audioName] ofType:@"mp3"]];
    
    NSError* error;
    AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    @try {
        [player prepareToPlay];
    }
    @catch(NSException* e) {
        
    }
    
    [audioNameToPlayer setValue:player forKey: audioName];
    return player;
}

- (void)playAudio:(NSString*)audioName {
    [self playAudio:audioName volume:1.0 pan:0.0];
}

- (void)stopAudio:(NSString*)audioName {
    AVAudioPlayer* player = [audioNameToPlayer valueForKey:audioName];
    [player stop];
}

- (void)playAudio:(NSString*)audioName volume:(float)volume pan:(float)pan {
    //if (alwaysPlayAudioEffects || !otherAudioIsPlaying){
        AVAudioPlayer* player = [audioNameToPlayer valueForKey:audioName];
        NSArray* params = [NSArray arrayWithObjects:player, [NSNumber numberWithFloat:volume],
                           [NSNumber numberWithFloat:pan], nil];
        [self performSelectorInBackground:@selector(playAudioInBackground:) withObject:params];
    //}
}

- (void)playAudioInBackground:(NSArray*)params{
    if ([params count]>0) {
        AVAudioPlayer* player = [params objectAtIndex:0];
        NSNumber* volume = [params objectAtIndex:1];
        NSNumber* pan = [params objectAtIndex:2];
        [player setCurrentTime:0];
        [player setVolume: [volume floatValue]];
        [player setPan: [pan floatValue]];
        [player play];
    }
}

- (void)handleAudioInterruption:(NSDictionary*)userInfo {
    [self stopAudio:@"pencil"];
    NSLog(@"%@",userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
