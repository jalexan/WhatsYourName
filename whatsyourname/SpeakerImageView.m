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
        
        
        
        defaultImagesArray = [NSMutableArray array];
        for (int i=0;i<FILE_CHECK_LITMIT;i++) {
            NSString* filename = [NSString stringWithFormat:@"Speakers/%@/Images/default%02d.png",speaker.name,i];
            UIImage* image = [UIImage imageNamed:filename];
            if (image) {
                [defaultImagesArray addObject:image];
            }
        }
    
        if ([defaultImagesArray count]==0) {
            NSLog(@"ERROR: Cannot find DEFAULT image files");
        }
        
        speakImagesArray = [NSMutableArray array];
        for (int i=0;i<FILE_CHECK_LITMIT;i++) {
            NSString* filename = [NSString stringWithFormat:@"Speakers/%@/Images/talking%02d.png",speaker.name,i];
            UIImage* image = [UIImage imageNamed:filename];
            if (image) {
                [speakImagesArray addObject:image];
            }
        }
    
        if ([speakImagesArray count]==0) {
            NSLog(@"ERROR: Cannot find TALK image files");
        }
        
    
        shuffleImagesArray = [NSMutableArray array];
        for (int i=0;i<FILE_CHECK_LITMIT;i++) {
            NSString* filename = [NSString stringWithFormat:@"Speakers/%@/Images/shuffle%02d.png",speaker.name,i];
            UIImage* image = [UIImage imageNamed:filename];
            if (image) {
                [shuffleImagesArray addObject:image];
            }

        }
        
        if ([shuffleImagesArray count]==0) {
            NSLog(@"ERROR: Cannot find SHUFFLe image files");
        }
    
        bravoImagesArray = [NSMutableArray array];
        for (int i=0;i<FILE_CHECK_LITMIT;i++) {
            NSString* filename = [NSString stringWithFormat:@"Speakers/%@/Images/bravo%02d.png",speaker.name,i];
            UIImage* image = [UIImage imageNamed:filename];
            if (image) {
                [bravoImagesArray addObject:image];
            }
            
        }
        
        if ([bravoImagesArray count]==0) {
            NSLog(@"ERROR: Cannot find BRAVO image files");
        }
        
        exitImagesArray = [NSMutableArray array];
        for (int i=0;i<FILE_CHECK_LITMIT;i++) {
            NSString* filename = [NSString stringWithFormat:@"Speakers/%@/Images/exit%02d.png",speaker.name,i];
            UIImage* image = [UIImage imageNamed:filename];
            if (image) {
                [exitImagesArray addObject:image];
            }
        }
        
        if ([exitImagesArray count]==0) {
            NSLog(@"ERROR: Cannot find EXIT image files");
        }
        
    }
    
    return self;
    
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
