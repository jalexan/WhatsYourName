//
//  ShuffleImageView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/8/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ShuffleImageView.h"

#define FILE_CHECK_LITMIT 30

@interface ShuffleImageView () {
    NSMutableArray* animationArray;
    Speaker* speaker;
    
}


@end

@implementation ShuffleImageView
@synthesize animationFound;

- (id)initWithFrame:(CGRect)frame speaker:(Speaker*)theSpeaker{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeBottomLeft;


        speaker = theSpeaker;

        animationArray = [[NSMutableArray alloc] init];
        
        [self addAnimationFilesToArray:animationArray filePrefix:@"running"];
    }
    return self;
}

- (BOOL)animationFound {
    return animationArray.count>0;
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


- (void)stopAnimatingSelector {
    [self stopAnimating];
}


- (void)animateWithDuration:(NSTimeInterval)duration {
    [self setAnimationImages: animationArray];
    [self setAnimationDuration: 1.85];
    [self setAnimationRepeatCount:0];
    [self startAnimating];
    
    [self performSelector:@selector(stopAnimatingSelector) withObject:nil afterDelay:duration];
    
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
