//
//  Tile.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ArabicLetter.h"

@interface ArabicLetter () {
    NSString* unicodeGeneralString;
    NSString* unicodeInitialString;
    NSString* unicodeMedialString;
    NSString* unicodeFinalString;
}

@end

@implementation ArabicLetter
@synthesize letterDictionary;
@synthesize letterIndex;
@synthesize letterName;
@synthesize slotPosition;
@synthesize isInCorrectSlot;
@synthesize unicodeGeneral;
@synthesize unicodeInitial;
@synthesize unicodeMedial;
@synthesize unicodeFinal;



- (id) initWithLetterIndex:(NSUInteger)index  {
    
    if ((self = [super init])) {
        letterIndex = index;
        
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"Letters"] ofType:@"plist"];
        
        NSArray* lettersArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
        
        
        if (index>=[lettersArray count]) {
            NSLog(@"ERROR: [lettersArray count] < index: %d", (unsigned int)index);
        }
        letterDictionary = [lettersArray objectAtIndex:index];
        
        letterName = [letterDictionary objectForKey:@"Name"];
        
        unicodeGeneralString = [letterDictionary objectForKey:@"Isolated"];
        unicodeInitialString = [letterDictionary objectForKey:@"Initial"];
        unicodeMedialString = [letterDictionary objectForKey:@"Medial"];
        unicodeFinalString = [letterDictionary objectForKey:@"Final"];
        
        isInCorrectSlot = NO;
        slotPosition = -1;
    }
    
    return self;
}

- (unichar)unicodeGeneral {
//    NSUInteger unicodeValue;
    unsigned int unicodeValue;

    [[NSScanner scannerWithString:unicodeGeneralString] scanHexInt:&unicodeValue];
     //NSLog(@"ERROR converting unicode char: %@",[NSString stringWithFormat:@"%C", charValue]);
    return (unichar)unicodeValue;

}


- (unichar)unicodeInitial {
    //    NSUInteger unicodeValue;
        unsigned int unicodeValue;
    
    [[NSScanner scannerWithString:unicodeInitialString] scanHexInt:&unicodeValue];
    //NSLog(@"%@",[NSString stringWithFormat:@"%C", charValue]);
    return (unichar)unicodeValue;
    
}

- (unichar)unicodeMedial {
    //    NSUInteger unicodeValue;
        unsigned int unicodeValue;
    [[NSScanner scannerWithString:unicodeMedialString] scanHexInt:&unicodeValue];
    //NSLog(@"%@",[NSString stringWithFormat:@"%C", charValue]);
    return (unichar)unicodeValue;
    
}

- (unichar)unicodeFinal {
    //    NSUInteger unicodeValue;
        unsigned int unicodeValue;
    
    [[NSScanner scannerWithString:unicodeFinalString] scanHexInt:&unicodeValue];
    //NSLog(@"%@",[NSString stringWithFormat:@"%C", charValue]);
    return (unichar)unicodeValue;
    
}



@end
