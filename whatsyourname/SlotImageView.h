//
//  SlotImageView.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/19/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Slot.h"

@interface SlotImageView : UIImageView

- (id)initWithFrame:(CGRect)frame slot:(Slot*)theSlot;
@property (nonatomic,readonly) Slot* slot;
@end
