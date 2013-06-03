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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self layoutSubviews];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder  {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self layoutSubviews];
        
    }
    return self;
}

- (void)layoutSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    CGSize circleSize = CGSizeMake(58,58);
    
    NSUInteger numberOfCircles = [SpeakerList sharedInstance].numberOfSpeakers;
    circleImageViewArray = [[NSMutableArray alloc] initWithCapacity:numberOfCircles];
    
    NSUInteger widthOfContent = (numberOfCircles+1)*(circleSize.width+10);
    NSUInteger originX = (self.bounds.size.width/2)-(widthOfContent/2)+10;
    
    for (int i=0;i<numberOfCircles;i++)
    {
        
        ProgressCircleImageView* circle = [[ProgressCircleImageView alloc] initWithImage:[UIImage imageNamed:DEFAULT_IMAGE]];
        //circle.contentMode = UIViewContentModeCenter;
        circle.frame = CGRectMake(originX,10,58,58);
        [self addSubview:circle];
        [circleImageViewArray addObject:circle];
        
        originX += (58 + 10);

    }
    
    
    surpriseCircle = [[ProgressCircleImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/progress_circle_mystery.png"]];
    surpriseCircle.frame = CGRectMake(originX,10,58,58);
    [self addSubview:surpriseCircle];
    
    /*
    UILabel* questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    questionLabel.backgroundColor = [UIColor clearColor];
    questionLabel.textColor = [UIColor greenColor];
    questionLabel.text = @"?";
    questionLabel.textAlignment = NSTextAlignmentCenter;
    questionLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
    [surpriseCircle addSubview:questionLabel];
    */

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


- (ProgressCircleImageView*)circleImageViewWithIndex:(NSUInteger)circleIndex {
    
    if (circleIndex<[circleImageViewArray count]) {
        ProgressCircleImageView* circle = [circleImageViewArray objectAtIndex:circleIndex];
        return circle;
    }
    
    return nil;
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
