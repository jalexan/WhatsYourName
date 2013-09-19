//
//  PlayButton.m
//  whatsyourname
//
//  Created by Richard Nguyen on 9/18/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "PlayButton.h"

@implementation PlayButton

- (void)animate {
    

    [UIView animateWithDuration:1.25
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:(void (^)(void)) ^{

                         CGAffineTransform scaleTransform =  CGAffineTransformMakeScale(1.25, 1.25);
                         self.transform = scaleTransform;
                     }
                     completion:^(BOOL finished){
                         self.transform = CGAffineTransformIdentity;
                     }];
    
 
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
