//
//  ActorImageView.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/15/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Speaker.h"

typedef enum {
    DEFAULT,
    TALK,
    SHUFFLE,
    BRAVO,
    EXIT,
    BYE
} AnimationType;

@interface SpeakerImageView : UIImageView {
    
}
@property (nonatomic,strong) Speaker* speaker;

- (id)initWithFrame:(CGRect)frame speaker:(Speaker*)theSpeaker;
- (void)animateWithType:(AnimationType)animationType repeatingDuration:(NSTimeInterval)duration;
- (void)animateWithType:(AnimationType)animationType repeatingDuration:(NSTimeInterval)repeatingDuration keepLastFrame:(BOOL)keepLastFrame;
- (void)repeatAnimation:(AnimationType)type;
- (void)stopRepeatingAnimations;
- (void)setToLastExitImage;
- (UIImage*)lastExitImage;
- (NSTimeInterval)animationDurationOfType:(AnimationType)animationType;
@end
