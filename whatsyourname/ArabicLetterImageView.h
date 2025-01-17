//
//  ArabicLetteImageView.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "ArabicLetter.h"

@interface ArabicLetterImageView : UIImageView

- (id)initWithArabicLetter:(ArabicLetter*)letter;
- (id)initWithArabicLetter:(ArabicLetter*)letter showName:(BOOL)show;

@property(nonatomic, strong) ArabicLetter* arabicLetter;
@property(nonatomic, assign) CGPoint dragStartPoint;
@property(nonatomic, assign) BOOL isAnimating;
@property(nonatomic, assign) BOOL showName;
@property(nonatomic, assign) NSUInteger fontSize;
@property(nonatomic, assign) UIColor *fontColor;
@property(nonatomic, assign) BOOL addShadows;
@property(nonatomic, assign) UIImage *frameImage;

@end
