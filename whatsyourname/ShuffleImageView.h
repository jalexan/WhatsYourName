//
//  ShuffleImageView.h
//  whatsyourname
//
//  Created by Richard Nguyen on 6/8/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Speaker.h"

@interface ShuffleImageView : UIImageView


- (id)initWithFrame:(CGRect)frame speaker:(Speaker*)theSpeaker;
- (void)animateWithDuration:(NSTimeInterval)duration;

@property (nonatomic,readonly) BOOL animationFound;
@end
