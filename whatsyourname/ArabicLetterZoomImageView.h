//
//  ArabicLetterZoomImageView.h
//  whatsyourname
//
//  Created by Julie Alexan on 7/16/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArabicLetterImageView.h"

@interface ArabicLetterZoomImageView : ArabicLetterImageView

- (id)initWithArabicLetter:(ArabicLetter*)letter;

@property (nonatomic,strong) NSString* letterSoundFile;

@end