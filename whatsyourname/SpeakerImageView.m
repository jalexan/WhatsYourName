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
    NSMutableArray* byeImagesArray;
    
    UIImage* mainSpeakerImage;
    
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
        mainSpeakerImage = [UIImage imageNamed:filename];
        self.image = mainSpeakerImage;
        [self animateWithType:DEFAULT repeatingDuration:3.5];
        
        defaultImagesArray = [[NSMutableArray alloc] init];
        speakImagesArray = [[NSMutableArray alloc] init];
        shuffleImagesArray = [[NSMutableArray alloc] init];
        bravoImagesArray = [[NSMutableArray alloc] init];
        exitImagesArray = [[NSMutableArray alloc] init];
        byeImagesArray = [[NSMutableArray alloc] init];
        
        [self addAnimationFilesToArray:defaultImagesArray filePrefix:@"default"];
        [self addAnimationFilesToArray:speakImagesArray filePrefix:@"talking"];
        [self addAnimationFilesToArray:shuffleImagesArray filePrefix:@"shuffle"];
        [self addAnimationFilesToArray:bravoImagesArray filePrefix:@"bravo"];
        [self addAnimationFilesToArray:exitImagesArray filePrefix:@"exit"];
        [self addAnimationFilesToArray:byeImagesArray filePrefix:@"bye"];
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
        self.animationImages = nil;
        self.image = mainSpeakerImage;
    }
}

- (void)animateWithType:(AnimationType)animationType repeatingDuration:(NSTimeInterval)repeatingDuration keepLastFrame:(BOOL)keepLastFrame {
        
     lastAnimationType = animationType;
     
     if (animationType==TALK) {                  
         [self setAnimationImages: speakImagesArray]; //1.5
         [self setAnimationDuration: (float)speakImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
         [self setAnimationRepeatCount:0];
         
     }
     else if (animationType==SHUFFLE) {
         if (keepLastFrame) {
             self.animationImages = nil;
             self.image = shuffleImagesArray.lastObject;
         }
         
         [self setAnimationImages: shuffleImagesArray]; //3
         [self setAnimationDuration: (float)shuffleImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
         [self setAnimationRepeatCount:1];

         
     }

     else if (animationType==BRAVO) {

         if (keepLastFrame) {
             self.animationImages = nil;
             self.image = bravoImagesArray.lastObject;
         }

         [self setAnimationImages: bravoImagesArray]; //1
         [self setAnimationDuration: (float)bravoImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
         [self setAnimationRepeatCount:1];

         
         
     }
     else if (animationType==EXIT) {
         [self setAnimationImages: exitImagesArray]; //1.65
         [self setAnimationDuration: (float)exitImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
         [self setAnimationRepeatCount:1];

         
     }
     else if (animationType==BYE) {
         [self setAnimationImages: byeImagesArray]; //1.65
         [self setAnimationDuration: (float)byeImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
         [self setAnimationRepeatCount:1];

         
         
     }
     else {
         
         [self setAnimationImages: defaultImagesArray]; //1
         [self setAnimationDuration: (float)defaultImagesArray.count/ANIMATION_FRAMES_PER_SECOND];
         [self setAnimationRepeatCount: 1];

         
     }
    
    
    [self startAnimating];
    
    
    if (animationType!=EXIT && animationType!=SHUFFLE) {
        NSTimeInterval afterDelay;
        if (self.animationRepeatCount==0) {
            afterDelay = repeatingDuration;
        }
        else {
            afterDelay = self.animationDuration;
        }
        
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimatingWithType:) object:[NSNumber numberWithInt:lastAnimationType]];
        [self performSelector:@selector(stopAnimatingWithType:) withObject:[NSNumber numberWithInt:lastAnimationType] afterDelay:afterDelay];
    
    }
    
}

- (void)animateWithType:(AnimationType)animationType repeatingDuration:(NSTimeInterval)repeatingDuration {
    [self animateWithType:animationType repeatingDuration:repeatingDuration keepLastFrame:NO];
}

- (NSTimeInterval)animationDurationOfType:(AnimationType)animationType {
    if (animationType==TALK) {
        return (float)speakImagesArray.count/ANIMATION_FRAMES_PER_SECOND;
    }
    else if (animationType==SHUFFLE) {
        return (float)shuffleImagesArray.count/ANIMATION_FRAMES_PER_SECOND;
    }
    else if (animationType==BRAVO) {
        
        return (float)bravoImagesArray.count/ANIMATION_FRAMES_PER_SECOND;

    }
    else if (animationType==EXIT) {
        return  (float)exitImagesArray.count/ANIMATION_FRAMES_PER_SECOND;
    }
    else if (animationType==BYE) {
        return (float)byeImagesArray.count/ANIMATION_FRAMES_PER_SECOND;
    }
    else {
        
        return  (float)defaultImagesArray.count/ANIMATION_FRAMES_PER_SECOND;

    }

}

- (void)setToLastExitImage {
    UIImage* image = [exitImagesArray lastObject];
    self.image = image;
}

- (UIImage*)lastExitImage {
    return [exitImagesArray lastObject];
}

- (void)repeatAnimationNumber:(NSNumber*)type {
    [self repeatAnimation:[type integerValue]];
}

- (void)repeatAnimation:(AnimationType)type {
    if ([self superview]) {
        if (!self.isAnimating && self.image == mainSpeakerImage) {
            [self animateWithType:type repeatingDuration:1];
        }
        
        NSUInteger randomDelay = (arc4random() % 3) + 4;
        
        [self performSelector:@selector(repeatAnimationNumber:) withObject:[NSNumber numberWithInt:type] afterDelay:randomDelay];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];        
    }
}

- (void)stopRepeatingAnimations {
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
