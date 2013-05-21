//
//  ViewController.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/11/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVAudioSessionDelegate> {
    //IBOutlet UIView* actorContainerView;
    IBOutlet UILabel* greetingLabel;
    IBOutlet UIView* arabicNameView;
    IBOutlet UIView* slotContainerView;
    IBOutlet UIView* mixedUpLettersAreaView;
    //IBOutlet UIButton* resetButton;
}

//- (IBAction)reset:(id)sender;

@end
