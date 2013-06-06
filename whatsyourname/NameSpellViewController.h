//
//  NameSpellViewController.h
//  whatsyourname
//
//  Created by Richard Nguyen on 6/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "GameController.h"

@interface NameSpellViewController : GameController {
    IBOutlet UIImageView* background;
    IBOutlet UILabel* dialogLabel;
    IBOutlet UILabel* arabicSpellLabel;
    IBOutlet UIView* letterContainerView;
    
    
}

@end
