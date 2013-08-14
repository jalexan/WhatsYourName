//
//  ArabicLetterAudioImageView.m
//  whatsyourname
//
//  Created by Julie Alexan on 7/16/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetterAudioImageView.h"

@implementation ArabicLetterAudioImageView {
    UITapGestureRecognizer *gr;
}

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
    
    gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    gr.numberOfTapsRequired=1;
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:gr];

    
    return self;
}



-(void)tap:(UITapGestureRecognizer*)sender {
    [self.audioManager playAudio:self.letterSoundFile volume:1];
    if (self.delegate && [self.delegate respondsToSelector:@selector(letterImageViewWasTouched)] ) {
        [self.delegate letterImageViewWasTouchedWith: self];  //just call the delegate's method directly
    }
}
//LEFT OFF HERE...move touch and letterSoundFile to the ViewController
//just add Zoom/Scale method here



@end
