//
//  Slot.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/19/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetter.h"

@interface Slot : NSObject {
    
    
}
- (id) initWithPosition:(NSUInteger)position;

@property (nonatomic,strong) ArabicLetter* arabicLetter;
@property (nonatomic,assign) NSUInteger position;
- (BOOL)isFilled;

@end
