//
//  Tile.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetter.h"

@interface ArabicLetter () {
    NSString* unicodeString;
}

@end

@implementation ArabicLetter
@synthesize letterDictionary;
@synthesize letterIndex;
@synthesize letterName;
@synthesize unicode;
@synthesize slotPosition;
@synthesize isInCorrectSlot;

- (id) initWithLetterIndex:(NSUInteger)index  {
    
    if ((self = [super init])) {
        letterIndex = index;
        
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"Letters/Info"] ofType:@"plist"];
        
        NSArray* lettersArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
        
        
        if (index>=[lettersArray count]) {
            NSLog(@"ERROR: [lettersArray count] < index: %d", index);
        }
        letterDictionary = [lettersArray objectAtIndex:index];
        
        letterName = [letterDictionary objectForKey:@"Name"];
        
        unicodeString = [letterDictionary objectForKey:@"Unicode"];
        
        isInCorrectSlot = NO;
        slotPosition = -1;
    }
    
    return self;
}

- (unichar)unicode {
    
    NSUInteger unicodeValue;
    [[NSScanner scannerWithString:unicodeString] scanHexInt:&unicodeValue];
    //NSLog(@"%@",[NSString stringWithFormat:@"%C", charValue]);
    return (unichar)unicodeValue;
    
}
@end
