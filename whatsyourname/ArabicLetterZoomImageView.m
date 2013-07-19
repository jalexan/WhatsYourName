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

//LEFT OFF HERE...move touch and letterSoundFile to the ViewController
//just add Zoom/Scale method here
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGAffineTransform scaleTransform =  CGAffineTransformMakeScale(10, 10);
    //CGAffineTransform transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformConcat(scaleTransform,scaleTransform);//CGAffineTransformConcat(self.transform,scaleTransform);
   // [self.letter resizedImage:newSize transform:transform drawTransposed:drawTransposed interpolationQuality:quality];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

@end
