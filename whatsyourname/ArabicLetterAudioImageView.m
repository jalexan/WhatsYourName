//
//  ArabicLetterAudioImageView.m
//  whatsyourname
//
//  Created by Julie Alexan on 7/16/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetterAudioImageView.h"

@implementation ArabicLetterAudioImageView
@synthesize delegate;
@synthesize audioManager;
@synthesize letterSoundFile;

- (id)initWithArabicLetter:(ArabicLetter*)letter andAudioManager:(AudioManager *)am withSound:(NSString *)sfile
{
    self = [super initWithArabicLetter:letter];
    self.showName = NO;
    self.audioManager = am;
    self.letterSoundFile = sfile;
    NSString* filename = [NSString stringWithFormat:@"Resource/slot_frame_light.png"];
    self.frameImage = [UIImage imageNamed:filename];
    self.addShadows = NO;
    self.fontColor = [UIColor whiteColor];
    self.fontSize = 28;
    
    return self;
}

//LEFT OFF HERE...move touch and letterSoundFile to the ViewController
//just add Zoom/Scale method here

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.audioManager playAudio:self.letterSoundFile volume:1];
    if (self.delegate && [self.delegate respondsToSelector:@selector(letterImageViewWasTouched)] ) {
        [self.delegate letterImageViewWasTouchedWith: self];  //just call the delegate's method directly
    }
    //LEFT OFF HERE - need to call zoom method on letter that was touched
/*    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.10, 1.10);
    self.transform = scaleTransform;
    
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    ArabicLetterAudioImageView* objectToDrag = (ArabicLetterAudioImageView*)touch.view;
    
    if ([objectToDrag isKindOfClass:[ArabicLetterImageView class]])
    {
        [self.view bringSubviewToFront:objectToDrag];
        objectToDrag.backgroundColor = [UIColor redColor];
        [objectToDrag.delegate zoomLetter];
    }
 */
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 
}


@end
