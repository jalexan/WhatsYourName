//
//  GameProgressView.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/23/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpeakerList.h"

@interface GameProgressView : UIView {
    
}

@property(nonatomic,readonly) NSMutableArray* circleImageViewArray;


- (void)setImage:(UIImage*)image forCircleIndex:(NSUInteger)circleIndex;
- (UIImageView*)circleImageViewWithIndex:(NSUInteger)circleIndex;
- (void)startRotations;
- (void)stopRotations;
@end
