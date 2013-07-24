//
//  GameUIButton.m
//  whatsyourname
//
//  Created by Richard Nguyen on 7/23/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "GameUIButton.h"
#import "AudioManager.h"

@implementation GameUIButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    AudioManager* audioManager = [AudioManager sharedInstance];
    [audioManager prepareAudioWithPath:@"Resource/buttonpress.mp3"];
    [audioManager playAudio:@"Resource/buttonpress.mp3" volume:1];
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
