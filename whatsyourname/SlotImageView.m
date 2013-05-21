//
//  SlotImageView.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/19/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "SlotImageView.h"

@interface SlotImageView () {
    Slot* slot;
}
@end

@implementation SlotImageView
@synthesize slot;

- (id)initWithFrame:(CGRect)frame slot:(Slot*)theSlot
{
    self = [super initWithFrame:frame];
    if (self) {
        slot = theSlot;
        
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"Resource/slot.png"]];
    }
    return self;
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
