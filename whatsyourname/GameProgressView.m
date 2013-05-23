//
//  GameProgressView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/23/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "GameProgressView.h"

@interface GameProgressView () {
    
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
    
    NSUInteger numberOfCircles = [SpeakerList sharedInstance].numberOfSpeakers;
    circleImageViewArray = [[NSMutableArray alloc] initWithCapacity:numberOfCircles];
    
    NSUInteger originX = 10;
    for (int i=0;i<numberOfCircles;i++)
    {
        
        UIImageView* circle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/progress_circle.png"]];
        circle.frame = CGRectMake(originX,10,44,44);
        [self addSubview:circle];
        [circleImageViewArray addObject:circle];
        
        originX += (44 + 10);
    }
    
    
    UIImageView* surpriseCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/progress_circle.png"]];
    surpriseCircle.frame = CGRectMake(originX,10,44,44);
    [self addSubview:surpriseCircle];
    UILabel* questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    questionLabel.backgroundColor = [UIColor clearColor];
    questionLabel.text = @"?";
    questionLabel.textAlignment = NSTextAlignmentCenter;
    questionLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
    [surpriseCircle addSubview:questionLabel];
    
}

- (UIImageView*)circleImageViewWithIndex:(NSUInteger)circleIndex {
    
    if (circleIndex<[circleImageViewArray count]) {
        
        
        UIImageView* circle = [circleImageViewArray objectAtIndex:circleIndex];
     
        return circle;
    }
    
    return nil;
}

- (void)setImage:(UIImage*)image forCircleIndex:(NSUInteger)circleIndex {
    
    if (circleIndex<[circleImageViewArray count]) {
        
        
        UIImageView* circle = [circleImageViewArray objectAtIndex:circleIndex];
        circle.image = image;
        
        
    }
    
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
