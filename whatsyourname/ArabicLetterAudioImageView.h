//
//  ArabicLetterAudioImageView.h
//  whatsyourname
//
//  Created by Julie Alexan on 7/16/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioManager.h"
#import "ArabicLetterImageView.h"

@protocol ArabicLetterAudioImageViewDelegate <NSObject>
-(void)letterImageViewWasTouchedWith: (ArabicLetterImageView*)letterImageView;
@end

@interface ArabicLetterAudioImageView : ArabicLetterImageView

- (id)initWithArabicLetter:(ArabicLetter*)letter andAudioManager:(AudioManager *)am withSound:(NSString *)sfile;

@property (nonatomic,strong) AudioManager *audioManager;
@property (nonatomic,assign) id <ArabicLetterAudioImageViewDelegate> delegate;
@property (nonatomic,strong) NSString* letterSoundFile;

@end