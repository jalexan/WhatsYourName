//
//  StarImageView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/14/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "StarImageView.h"

#define ARC4RANDOM_MAX  0x100000000
#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@implementation StarImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage* image = [UIImage imageNamed:@"Resource/star.png"];
        self.image = image;

    }
    
    
    
    return self;
}




- (void)animateWithEndPoint:(CGPoint)theEndPoint completion:(void(^)())completion {
    
    //int randomX = (arc4random() % 600)-300;
    
    //CGPoint startPoint = self.center;
    //CGPoint endPoint = CGPointMake(startPoint.x+=randomX,startPoint.y-400);
    
    
    //float randomDuration = ((float)arc4random()/ARC4RANDOM_MAX)*9;
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:(void (^)(void)) ^{
                         //NSLog(@"%d",randomX);
                         self.center = theEndPoint;
                         
                         //CGRect r = imageViewToAnimate.frame;
                         //r.size = CGSizeMake(0,0);
                         //imageViewToAnimate.frame = r;
                         CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
                         CGAffineTransform scaleTransform =  CGAffineTransformMakeScale(0, 0);
                         
                         //imageViewToAnimate.transform = scaleTransform;
                         self.transform = CGAffineTransformConcat(rotateTransform,scaleTransform);//CGAffineTransformConcat(self.transform,scaleTransform);
                         
                     }
                     completion:^(BOOL finished){
                         [self stopAnimating];
                         [self removeFromSuperview];
                         completion();
                     }];
    
    
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"step1"]) {
        [UIView beginAnimations:@"step2" context:NULL]; {
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            [UIView setAnimationDelegate:self];
            self.transform = CGAffineTransformMakeRotation(240 * M_PI / 180);
        } [UIView commitAnimations];
    }
    else if ([animationID isEqualToString:@"step2"]) {
        [UIView beginAnimations:@"step3" context:NULL]; {
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            [UIView setAnimationDelegate:self];
            self.transform = CGAffineTransformMakeRotation(0);
        } [UIView commitAnimations];
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
