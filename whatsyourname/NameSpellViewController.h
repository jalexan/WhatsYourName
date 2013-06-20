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
    IBOutlet UILabel* arabicSpellLabel;
    IBOutlet UIView* letterContainerView;
    
    
}

@property (nonatomic, strong) NSString* playerName;
@property (nonatomic, readonly) NSDictionary* knownNamesDictionary;
@property (nonatomic, readonly) NSDictionary* transliterationDictionary;
@property (nonatomic, readonly) NSDictionary* arabicLettersByNameDictionary;
@property (nonatomic, readonly) NSArray* arabicLettersDictionary;

@end
