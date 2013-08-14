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
    
    [self setUserInteractionEnabled:YES];
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.audioManager prepareAudioWithPath:self.letterSoundFile];
    [self.audioManager playAudio:self.letterSoundFile volume:1];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(letterImageViewWasTouchedWith:)] ) {
        [self.delegate letterImageViewWasTouchedWith:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(letterImageViewTouchesStopped:)] ) {
        [self.delegate letterImageViewTouchesStopped:self];
    }
}


@end
