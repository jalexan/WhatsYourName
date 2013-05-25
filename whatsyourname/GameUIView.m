//
//  GameUIView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/24/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "GameUIView.h"

@implementation GameUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setFrame:(CGRect)newFrame   {
    

    CGRect tempBounds = [[UIScreen mainScreen] bounds];
    
    //Check for 4inch screen
    if (tempBounds.size.height==568 || tempBounds.size.width==568) {
        CGRect r;
        r.size = CGSizeMake(480, 320);
        r.origin = CGPointMake(44, 0);

        
        [super setFrame:r];
    }
 
    else {
        [super setFrame:newFrame];
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
