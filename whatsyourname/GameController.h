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
    IBOutlet UIButton* soundButton;
}

@property (nonatomic,strong) AudioManager* audioManager;
@property (nonatomic,strong) IBOutlet UIButton* soundButton;

- (void)playSpeakerDialogAudioWithKey:(NSString*)key prefix:(NSString*)prefix  suffix:(NSString*)suffix;
- (IBAction)soundButtonTouched:(id)sender;

@end

