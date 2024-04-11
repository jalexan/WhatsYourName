//
//  ArabicLetteImageView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetterImageView.h"
#import "UIView+Additions.h"

@interface ArabicLetterImageView() {
    UILabel* letterLabel;
    UILabel* letterNameLabel;
}

@end

@implementation ArabicLetterImageView
@synthesize arabicLetter;
@synthesize dragStartPoint;
@synthesize showName;
@synthesize fontSize;
@synthesize fontColor;
@synthesize frameImage;

- (id)initWithArabicLetter:(ArabicLetter*)letter
{
    self = [super init];
    if (self) {
        
        self.arabicLetter = letter;
        self.userInteractionEnabled = YES;
        self.showName = YES;
        self.addShadows = YES;
    }
    return self;
}

- (id)initWithArabicLetter:(ArabicLetter*)letter showName:(BOOL)show
{
    self = [super init];
    if (self) {
        
        self.arabicLetter = letter;
        self.userInteractionEnabled = YES;
        self.showName = show;
        self.addShadows = YES;
    }
    return self;
}

-(void) setShowName:(BOOL)show {
    showName = show;
    if (showName) {
        letterNameLabel = [[UILabel alloc] init];
        letterNameLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15];
        letterNameLabel.backgroundColor = [UIColor clearColor];
        letterNameLabel.textAlignment = NSTextAlignmentCenter;
        letterNameLabel.shadowColor = [UIColor whiteColor];
        letterNameLabel.shadowOffset = CGSizeMake(0,1);
        letterNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        letterNameLabel.numberOfLines = 2;
        
        letterNameLabel.text = arabicLetter.letterName;
        [letterNameLabel sizeToFit];
        [self addSubview:letterNameLabel];
    }
}

- (void)setArabicLetter:(ArabicLetter *)theArabicLetter {
    arabicLetter = theArabicLetter;
    
    //NSString* filename = [NSString stringWithFormat:@"Letters/%02d.png",arabicLetter.letterIndex];
    if (!self.image) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"Resource/slot_frame.png"]];
    }
    
    self.frameImage = self.image;
   // if (self.frameImage) {
   //     self.image = self.frameImage;
   // }

    if (!self.fontSize) fontSize = 36;
    if (!self.fontColor) fontColor = [UIColor blackColor];
    letterLabel = [[UILabel alloc] init];
    letterLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:self.fontSize];
    letterLabel.textColor = self.fontColor;
    letterLabel.backgroundColor = [UIColor clearColor];
    letterLabel.textAlignment = NSTextAlignmentCenter;
    letterLabel.adjustsFontSizeToFitWidth = YES;
    letterLabel.numberOfLines = 1;
    if (self.addShadows) {
        letterLabel.shadowColor = [UIColor whiteColor];
        letterLabel.shadowOffset = CGSizeMake(1,1);
    }
    
    letterLabel.text = [NSString stringWithFormat:@"%C",arabicLetter.unicodeGeneral];
    [self addSubview:letterLabel];
    
    if (self.showName) {
        letterNameLabel = [[UILabel alloc] init];
        letterNameLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15];
        letterNameLabel.backgroundColor = [UIColor clearColor];
        letterNameLabel.textAlignment = NSTextAlignmentCenter;
        letterNameLabel.shadowColor = [UIColor whiteColor];
        letterNameLabel.shadowOffset = CGSizeMake(0,1);
        letterNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        letterNameLabel.numberOfLines = 2;
    
        letterNameLabel.text = arabicLetter.letterName;
        [letterNameLabel sizeToFit];
        [self addSubview:letterNameLabel];
    }
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    letterLabel.frame = self.bounds;
    
    
    CGRect labelFrame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width+10, 50);
    letterNameLabel.frame = labelFrame;
    [letterNameLabel sizeToFit];
    
    CGRect r = letterNameLabel.frame;
    r.origin.x = (self.width/2)-(r.size.width/2);
    letterNameLabel.frame = r;
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
