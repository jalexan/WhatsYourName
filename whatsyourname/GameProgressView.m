//
//  GameProgressView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/23/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GameProgressView.h"

#define DEFAULT_IMAGE @"Resource/progress_circle_upcoming.png"

@interface GameProgressView () {
    ProgressCircleImageView* surpriseCircle;
}

@end

@implementation GameProgressView
@synthesize circleImageViewArray;
@synthesize currentLevelCircleIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setNeedsDisplay];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder  {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setNeedsDisplay];
        
    }
    return self;
}

- (void)layoutSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    UIImage* coinImage = [UIImage imageNamed:DEFAULT_IMAGE];
    CGSize circleSize = CGSizeMake(coinImage.size.width,coinImage.size.height);
    
    NSUInteger numberOfCircles = [SpeakerList sharedInstance].numberOfSpeakers;
    circleImageViewArray = [[NSMutableArray alloc] initWithCapacity:numberOfCircles];
    
    //NSUInteger widthOfContent = (numberOfCircles+1)*(circleSize.width+52);
    NSUInteger originX = 0;// (self.bounds.size.width/2)-(widthOfContent/2)+52;
    
    for (int i=0;i<numberOfCircles;i++)
    {
        
        ProgressCircleImageView* circle = [[ProgressCircleImageView alloc] initWithImage:coinImage];
        //circle.contentMode = UIViewContentModeCenter;
        circle.frame = CGRectMake(originX,0,circleSize.width,circleSize.height);
        [self addSubview:circle];
        [circleImageViewArray addObject:circle];
        
        originX += (58 + 52);

    }
    
    
    surpriseCircle = [[ProgressCircleImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/progress_circle_mystery.png"]];
    surpriseCircle.frame = CGRectMake(originX,0,58,58);
    [self addSubview:surpriseCircle];


}

- (void)setCurrentLevelCircleIndex:(NSUInteger)index {
    if (index<[circleImageViewArray count]) {
        ProgressCircleImageView* circle = [circleImageViewArray objectAtIndex:index];
        circle.hidden = YES;
    }
    
}

- (void)setImage:(UIImage*)image atCircleIndex:(NSUInteger)index {
    if (index<[circleImageViewArray count]) {
        ProgressCircleImageView* circle = [circleImageViewArray objectAtIndex:index];
        [circle.layer removeAllAnimations];
        circle.image = image;
        circle.isComplete = YES;
        circle.hidden = NO;
    }
}

- (ProgressCircleImageView*)circleImageViewWithIndex:(NSUInteger)index {
    
    if (index<[circleImageViewArray count]) {
        ProgressCircleImageView* circle = [circleImageViewArray objectAtIndex:index];
        return circle;
    }
    
    return nil;
}


- (void)rotateImage:(UIImageView*)image {
    
    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.toValue = [NSNumber numberWithFloat:0];
    fullRotation.duration = 2.0f;
    fullRotation.repeatCount = MAXFLOAT;
    
    [image.layer addAnimation:fullRotation forKey:@"360"];
    
}

- (void)startRotations {
    
    for (ProgressCircleImageView* circle in circleImageViewArray) {
        if (!circle.isComplete) {
            [self rotateImage:circle];
        }
    }
    [self rotateImage:surpriseCircle];
    
}


- (void)stopRotations {
    
    for (ProgressCircleImageView* circle in circleImageViewArray) {
        [circle.layer removeAllAnimations];
    }
    
    [surpriseCircle.layer removeAllAnimations];
    
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
