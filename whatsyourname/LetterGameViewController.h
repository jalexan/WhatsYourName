//
//  LetterGameViewController.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/11/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameController.h"
#import "GameProgressView.h"



@interface LetterGameViewController : GameController {
    IBOutlet UIView* arabicNameView;
    IBOutlet UIView* slotContainerView;
    IBOutlet UIView* mixedUpLettersAreaView;
    IBOutlet GameProgressView* gameProgressView;    
}


@end
