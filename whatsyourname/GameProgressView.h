//
//  GameProgressView.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/23/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpeakerList.h"
#import "ProgressCircleImageView.h"

@interface GameProgressView : UIView {
    
}

@property(nonatomic,readonly) NSMutableArray* circleImageViewArray;
@property(nonatomic,assign) NSUInteger currentLevelCircleIndex;

- (void)setCurrentLevelCircleIndex:(NSUInteger)index;
- (void)setImage:(UIImage*)image atCircleIndex:(NSUInteger)index;
- (ProgressCircleImageView*)circleImageViewWithIndex:(NSUInteger)index;
- (void)startRotations;
- (void)stopRotations;

@end
