//
//  ArabicLetterZoomImageView.m
//  whatsyourname
//
//  Created by Julie Alexan on 7/16/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetterZoomImageView.h"

@implementation ArabicLetterZoomImageView
@synthesize letterSoundFile;

- (id)initWithArabicLetter:(ArabicLetter*)letter
{
    self = [super initWithArabicLetter:letter];
    self.showName = NO;
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

@end
