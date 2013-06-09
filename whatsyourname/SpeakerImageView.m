//
//  ActorImageView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/15/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#define FILE_CHECK_LITMIT 30

#import "SpeakerImageView.h"
@interface SpeakerImageView() {
    
    NSMutableArray* defaultImagesArray;
    NSMutableArray* speakImagesArray;
    NSMutableArray* shuffleImagesArray;
    NSMutableArray* bravoImagesArray;
    NSMutableArray* exitImagesArray;
    
    AnimationType lastAnimationType;
}

@end

@implementation SpeakerImageView
@synthesize speaker;

- (id)initWithFrame:(CGRect)frame speaker:(Speaker*)theSpeaker {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeBottomLeft;
        
        speaker = theSpeaker;
        
        NSString* filename = [NSString stringWithFormat:@"Speakers/%@/Images/default%02d.png",speaker.name,0];
        self.image = [UIImage imageNamed:filename];
        [self animateWithType:DEFAULT duration:3.5];
        
        defaultImagesArray = [[NSMutableArray alloc] init];
        speakImagesArray = [[NSMutableArray alloc] init];
        shuffleImagesArray = [[NSMutableArray alloc] init];
        bravoImagesArray = [[NSMutableArray alloc] init];
        exitImagesArray = [[NSMutableArray alloc] init];
        
        [self addAnimationFilesToArray:defaultImagesArray filePrefix:@"default"];
        [self addAnimationFilesToArray:speakImagesArray filePrefix:@"talking"];
        [self addAnimationFilesToArray:shuffleImagesArray filePrefix:@"shuffle"];
        [self addAnimationFilesToArray:bravoImagesArray filePrefix:@"bravo"];
        [self addAnimationFilesToArray:exitImagesArray filePrefix:@"exit"];        
    }
    
    return self;
    
}

- (void)addAnimationFilesToArray:(NSMutableArray*)array filePrefix:(NSString*)filePrefix {
    
    for (int i=0;i<FILE_CHECK_LITMIT;i++) {
        NSString* filename = [NSString stringWithFormat:@"Speakers/%@/Images/%@%02d.png",speaker.name,filePrefix,i];
        UIImage* image = [UIImage imageNamed:filename];
        if (image) {
            [array addObject:image];
        }
    }
    
    if ([array count]==0) {
        NSLog(@"ERROR: Cannot find %@ animation image files",filePrefix);
    }
}

- (void)stopAnimatingWithType:(NSNumber*)typeObject {
    int type = [typeObject intValue];
    
    if (lastAnimationType==type) {
        [self stopAnimating];
    }
}

- (void)animateWithType:(AnimationType)animationType duration:(NSTimeInterval)duration {
    lastAnimationType = animationType;
    
    if (animationType==TALK) {
        

        [self setAnimationImages: speakImagesArray]; //1.5
        [self setAnimationDuration: speakImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
        [self setAnimationRepeatCount:0];
        [self startAnimating];
        
        [self performSelector:@selector(stopAnimatingWithType:) withObject:[NSNumber numberWithInt:lastAnimationType] afterDelay:duration];
    }
    else if (animationType==SHUFFLE) {
        [self setAnimationImages: shuffleImagesArray]; //3
        [self setAnimationDuration: shuffleImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
        [self setAnimationRepeatCount:1];
        [self startAnimating];

    }
    else if (animationType==BRAVO) {
        [self setAnimationImages: bravoImagesArray]; //1
        [self setAnimationDuration:bravoImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
        [self setAnimationRepeatCount:1];
        [self startAnimating];

    }
    else if (animationType==EXIT) {
        [self setAnimationImages: exitImagesArray]; //1.65
        [self setAnimationDuration: exitImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
        [self setAnimationRepeatCount:1];
        [self startAnimating];

    }
    else {
        
        [self setAnimationImages: defaultImagesArray]; //1
        [self setAnimationDuration: defaultImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
        [self setAnimationRepeatCount: 1];
        [self startAnimating];

        [self performSelector:@selector(stopAnimatingWithType:) withObject:[NSNumber numberWithInt:lastAnimationType] afterDelay:1];
    }
}

- (void)setToLastExitImage {
    UIImage* image = [exitImagesArray lastObject];
    self.image = image;
}

- (UIImage*)lastExitImage {
    return [exitImagesArray lastObject];;
}

- (void)animateWithDefaultAnimation {
    if ([self superview]) {
        if (!self.isAnimating) {
            [self animateWithType:DEFAULT duration:1];
        }
        
        NSUInteger randomDelay = (arc4random() % 3) + 4;
        
        [self performSelector:@selector(animateWithDefaultAnimation) withObject:nil afterDelay:randomDelay];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];        
    }
}

- (void)stopDefaultAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];  
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
