//
//  Character.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "Speaker.h"
#import "ArabicLetter.h"

@interface Speaker () {

}
@end

@implementation Speaker
@synthesize name;
@synthesize dialogDictionary;
@synthesize letterIndexArray;

- (id) initWithName:(NSString*)theName  {
    
    if ((self = [super init])) {
        name = theName;
        
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"Speakers/%@/Info",name] ofType:@"plist"];
        
        NSDictionary* speakerInfoDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        dialogDictionary = [speakerInfoDictionary objectForKey:@"Dialog"];
        letterIndexArray = [speakerInfoDictionary objectForKey:@"Letters"];
    }
    
    return self;
}

- (NSString*)unicodeName {
    NSMutableString* string = [[NSMutableString alloc] init];
    for (int i=0;i<letterIndexArray.count;i++) {
        ArabicLetter* letter = [[ArabicLetter alloc] initWithLetterIndex:[letterIndexArray[i] intValue]];
        [string appendFormat:@"%C",letter.unicodeGeneral];
    }
    
    return string;
}

+ (NSString*)uniCodeNameWithLetterIndexArray:(NSArray*)letterIndexArray {
 
    NSMutableString* string = [[NSMutableString alloc] init];
    int previousLetterIndex = -1;
    NSUInteger limit = letterIndexArray.count - 1;  // 0-based array
    
    for (int index=0;index<letterIndexArray.count;index++) {
        ArabicLetter* letter = [[ArabicLetter alloc] initWithLetterIndex:[letterIndexArray[index] intValue]];

        if (index>0) {
            previousLetterIndex = [[letterIndexArray objectAtIndex:index-1] intValue];
        }
        
        unichar unicodeChar;
        if (letterIndexArray.count==1) {
            unicodeChar = letter.unicodeGeneral;
        }
        else if (index==0) { //first letter
            unicodeChar = letter.unicodeInitial;
        }
        else { //middle or last letter
            
            if (index>0 && (previousLetterIndex==0 ||
                            previousLetterIndex==31 ||
                            previousLetterIndex==32 ||
                            previousLetterIndex==33 ||
                            previousLetterIndex==34 ||
                            previousLetterIndex==7 ||
                            previousLetterIndex==8 ||
                            previousLetterIndex==9 ||
                            previousLetterIndex==10 ||
                            previousLetterIndex==26 ||
                            previousLetterIndex==28))
            {
                if (index==limit) { //last letter special
                    unicodeChar = letter.unicodeGeneral;
                }
                else {  //middle letter special
                    unicodeChar = letter.unicodeInitial;
                }
            }
            else if (index==limit) { //last letter
                unicodeChar = letter.unicodeFinal;
            }
            else { //middle letter
                unicodeChar = letter.unicodeMedial;
            }
            
            
        }
        
        
        [string appendFormat:@"%C",unicodeChar];
        

    }
    
    return string;
    
}



- (NSDictionary*)dialogForKey:(NSString*)key {
    return [dialogDictionary objectForKey:key];
}


@end
