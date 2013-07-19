//
//  GameController.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/27/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+Additions.h"
#import "AudioManager.h"

@interface GameController : UIViewController {
    
    IBOutlet UIButton* homeButton;
    IBOutlet UIButton* soundButton;
    IBOutlet UILabel* dialogLabel;
}

@property (nonatomic,readonly) CGSize screenBounds;
@property (nonatomic,weak) AudioManager* audioManager;


- (NSTimeInterval)getDurationAndPlaySpeakerDialogAudioWithKey:(NSString*)key prefix:(NSString*)prefix  suffix:(NSString*)suffix;
- (NSTimeInterval)getDurationDialogAudioWithKey:(NSString*)key prefix:(NSString*)prefix  suffix:(NSString*)suffix;
- (void)stopAllAudio;

- (IBAction)soundButtonTouched:(id)sender;

@end

