//
//  NameGameViewController.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/21/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameController.h"

@interface NameGameViewController : GameController <UITextFieldDelegate> {
    IBOutlet UIImageView* background;
    IBOutlet UITextField* nameTextField;
    IBOutlet UIButton* goodByeButton;
    IBOutlet UIButton* restartButton;
}

- (IBAction)goodByeButtonTouched:(id)sender;
//- (IBAction)restartButtonTouched:(id)sender;
@end
