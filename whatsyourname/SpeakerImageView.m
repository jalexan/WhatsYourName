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
}
@end

@implementation SpeakerImageView
@synthesize speaker;

- (id)initWithFrame:(CGRect)frame speaker:(Speaker*)theSpeaker
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.contentMode = UIViewContentModeBottomLeft;
        self.contentMode = UIViewContentModeScaleAspectFit;
        
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



- (void)animateWithType:(animationType)animationType duration:(NSTimeInterval)duration {
    if (animationType==TALK) {
        
        [self setAnimationImages: speakImagesArray];
        [self setAnimationDuration: 1.5];
        [self setAnimationRepeatCount:0];
        [self startAnimating];
        
        RunBlockAfterDelay(duration, ^() {                    
            [self stopAnimating];
        });
    }
    else if (animationType==SHUFFLE) {
        [self setAnimationImages: shuffleImagesArray];
        [self setAnimationDuration: 3];
        [self setAnimationRepeatCount:1];
        [self startAnimating];
        
        RunBlockAfterDelay(duration, ^() {
            [self stopAnimating];
        });
    }
    else if (animationType==BRAVO) {
        [self setAnimationImages: bravoImagesArray];
        [self setAnimationDuration:1];
        [self setAnimationRepeatCount:0];
        [self startAnimating];
        
        RunBlockAfterDelay(duration, ^() {
            [self stopAnimating];
        });
    }
    else if (animationType==EXIT) {
        [self setAnimationImages: exitImagesArray];
        [self setAnimationDuration: 1];
        [self setAnimationRepeatCount:1];
        [self startAnimating];
        
        RunBlockAfterDelay(duration, ^() {
            [self stopAnimating];
        });
    }
    else {
        
        [self setAnimationImages: defaultImagesArray];
        [self setAnimationDuration: 1];
        [self setAnimationRepeatCount: 1];
        [self startAnimating];
        
        RunBlockAfterDelay(duration, ^() {
            [self stopAnimating];
        });
    }
}

- (void)setToLastExitImage {
    UIImage* image = [exitImagesArray lastObject];
    self.image = image;
}

- (void)animateWithDefaultAnimation {
    if ([self superview]) {
        if (!self.isAnimating) {
            [self animateWithType:DEFAULT duration:1];
        }
        [self performSelector:@selector(animateWithDefaultAnimation) withObject:nil afterDelay:4];
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
