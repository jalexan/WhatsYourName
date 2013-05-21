//
//  Slot.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/19/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "Slot.h"

@interface Slot () {
    ArabicLetter* arabicLetter;
}

@end


@implementation Slot
@synthesize arabicLetter;
@synthesize position;

- (id) initWithPosition:(NSUInteger)thePosition  {
    
    if ((self = [super init])) {
        position = thePosition;
        
    }    
    return self;
}

- (BOOL)isFilled {
    return arabicLetter!=nil;
}


@end
