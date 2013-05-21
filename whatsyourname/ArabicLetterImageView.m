//
//  ArabicLetteImageView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetterImageView.h"


@implementation ArabicLetterImageView
@synthesize arabicLetter;
@synthesize dragStartPoint;

- (id)initWithArabicLetter:(ArabicLetter*)letter
{
    self = [super init];
    if (self) {
       
        self.arabicLetter = letter;
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (void)setArabicLetter:(ArabicLetter *)theArabicLetter {
    arabicLetter = theArabicLetter;
    
    NSString* filename = [NSString stringWithFormat:@"Letters/%02d.png",arabicLetter.letterIndex];
    UIImage* i = [UIImage imageNamed:filename];
    
    if (i) {
        self.image = i;
    }
    else {
        NSLog(@"Error: letter file not found: %@",filename);
    }
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
