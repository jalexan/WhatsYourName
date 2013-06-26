//
//  NameSpellViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "NameSpellViewController.h"
#import "ArabicLetter.h"
#import "ArabicLetterImageView.h"
#import "SpeakerList.h"

#define DEBUG_ARABIC_NAME 1

@interface NameSpellViewController () {
    NSDictionary* yourNameDialogDictionary;
    Speaker* mainSpeaker;
    NSMutableArray* arabicLettersArray;
    NSMutableArray* letterImageViewArray;
}

@end

@implementation NameSpellViewController
@synthesize playerName;
@synthesize knownNamesDictionary;
@synthesize transliterationDictionary;
@synthesize arabicLettersByNameDictionary;
@synthesize arabicLettersDictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!playerName)
        return;
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"YourNameDialog"] ofType:@"plist"];
    
    mainSpeaker = [SpeakerList sharedInstance].speakerArray[0];
    yourNameDialogDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    plistPath =  [bundle pathForResource:[NSString stringWithFormat:@"WellKnownNames"] ofType:@"plist"];
    knownNamesDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    plistPath = [bundle pathForResource:[NSString stringWithFormat:@"TransliteratedLetters"] ofType:@"plist"];
    transliterationDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    plistPath = [bundle pathForResource:[NSString stringWithFormat:@"LettersByName"] ofType:@"plist"];
    arabicLettersByNameDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    plistPath = [bundle pathForResource:[NSString stringWithFormat:@"Letters"] ofType:@"plist"];
    arabicLettersDictionary = [[NSArray alloc] initWithContentsOfFile:plistPath];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!playerName)
        return;

    arabicLettersArray = [self translatedLetterArrayForEnglishName:playerName];
    
    [self createLetterImageViewArray];
    
    [self displayDialogTextWithKey:@"LikeThis" completion:^() {
        
        //arabicSpellLabel
        
        [self animateArabicNameImageViewWithIndex:0 limit:arabicLettersArray.count-1 completion:^() {
            
            dispatch_after(DISPATCH_SECONDS_FROM_NOW(4), dispatch_get_current_queue(), ^{
                
                [self.navigationController popViewControllerAnimated:YES];
            });

            
        }];
        
    }];
    
}

/*
- (NSString*)translatedLetterArrayForEnglishName:(NSString*)name {
    NSMutableArray* letters = [[NSMutableArray alloc] init];
    
    //TODO: Given the name passed in, return an array of arabic letter indexes
    //letter index 0 corresponds to the arabic letter "alef"
    
    //Loop through each charater
    for (NSUInteger i=0;i<name.length;i++) {
        unichar currentChar = [name characterAtIndex:i];
        NSLog(@"%C",currentChar);
        // 'a' and 'e' in the middle position will take their nil values if between 2 constanants (i.e. they don't have a vowel as a neighbor)
        //
 
    }
    
    
    
    return letters;
}
 */

- (void)createLetterImageViewArray {
    NSUInteger numberOfLetters = arabicLettersArray.count;
    letterImageViewArray = [NSMutableArray arrayWithCapacity:numberOfLetters];
    CGSize letterImageSize = CGSizeMake(50, 50);
    
    NSUInteger containerWidth = numberOfLetters*letterImageSize.width;
    if (containerWidth > letterContainerView.superview.frame.size.width-24) {
        containerWidth = letterContainerView.superview.frame.size.width-24;
    }
    
    CGRect containerFrame = letterContainerView.frame;
    containerFrame.size.width = containerWidth;
    letterContainerView.frame = containerFrame;
    letterContainerView.centerX = letterContainerView.superview.centerX;
   
    
    NSInteger originY = 0;
    NSInteger heightToDivideEvenly = letterContainerView.height - letterImageSize.height; //Distance of origin of lowest slot to top of container
    
    NSInteger originYStep = 0;
    NSInteger numberOfSteps = 0;
    
    if (numberOfLetters>2) {
        if (numberOfLetters%2==0) { //Even # of letters
            numberOfSteps = (numberOfLetters/2)-1;
        }
        else { //Odd # of letters
            numberOfSteps = (numberOfLetters/2);
        }
        originYStep = heightToDivideEvenly/numberOfSteps;
    }
    else {
        numberOfSteps = 0;
        originYStep = heightToDivideEvenly;
    }
    
    
    for (int i=0;i<numberOfLetters;i++) {
        
        if (i>0) {
            if (i<=numberOfSteps) { //On the way down
                originY += originYStep;
            }
            else if (numberOfLetters%2==1 || i!=(numberOfSteps+1)) {
                originY -= originYStep;
            }
        }
        
        
        CGRect r = CGRectMake((letterContainerView.width-letterImageSize.width)-(letterImageSize.width*i), originY, letterImageSize.width, letterImageSize.height);
        ArabicLetter* l = [[ArabicLetter alloc] initWithLetterIndex:[arabicLettersArray[i] intValue]];
        ArabicLetterImageView* letterImageView = [[ArabicLetterImageView alloc] initWithArabicLetter:l];
        letterImageView.alpha = 0;
        
        letterImageView.frame = r;
        [letterContainerView addSubview:letterImageView];
        
        [letterImageViewArray addObject:letterImageView];
     
    }

}

- (void)animateArabicNameImageViewWithIndex:(NSUInteger)index limit:(NSUInteger)limit completion:(void(^)())completion {
    
    if (index>limit) {
        completion();
        return;
    }

    
    //Arabic Tiles
    NSUInteger letterIndex = [[arabicLettersArray objectAtIndex:index] intValue];
    ArabicLetter* letter = [[ArabicLetter alloc] initWithLetterIndex:letterIndex];
    NSUInteger previousLetterIndex;
    letter.slotPosition = index;
    
    if (index>0) {
        previousLetterIndex = [[arabicLettersArray objectAtIndex:index-1] intValue];
    }
    
    ArabicLetterImageView* letterImageView = letterImageViewArray[index];
    
    
    //Spell out each letter in dialog label
    if (index==0) arabicSpellLabel.text = @"";
    
    unichar unicodeChar;
    if (index==0) { //first letter
        unicodeChar = letter.unicodeInitial;
    }
    else if (index==limit) { //last letter
        unicodeChar = letter.unicodeFinal;
    }
    else { //middle letter

        if (index>0 && (previousLetterIndex==0 ||
                        previousLetterIndex==31 ||
                        previousLetterIndex==32 ||
                        previousLetterIndex==33 ||
                        previousLetterIndex==7 ||
                        previousLetterIndex==8 ||
                        previousLetterIndex==9 ||
                        previousLetterIndex==10 ||
                        previousLetterIndex==26 ||
                        previousLetterIndex==28))
        {
            unicodeChar = letter.unicodeInitial;
        }
        else {
            unicodeChar = letter.unicodeMedial;
        }
        
    }    
    arabicSpellLabel.text = [NSString stringWithFormat:@"%@%C",arabicSpellLabel.text,unicodeChar];


    [UIView animateWithDuration: 2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         letterImageView.alpha = 1;
                         
                     }
                     completion:^(BOOL finished){
                         [self animateArabicNameImageViewWithIndex:index+1 limit:limit completion:completion];
                     }];
    
}

- (void)displayDialogTextWithKey:(NSString*)key completion:(void(^)())completion {
    
    NSDictionary* dialogDictionary = [yourNameDialogDictionary objectForKey:key];
    if (!dialogDictionary)
        return;
    
    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = [dialogDictionary objectForKey:@"Arabic"];

    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:dialogLabel.font.pointSize];
    dialogLabel.text = text;
    
    
    NSTimeInterval dialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:mainSpeaker.name suffix:@"English"];
    dispatch_after(DISPATCH_SECONDS_FROM_NOW(dialogDuration), dispatch_get_current_queue(), ^{
        
        dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:dialogLabel.font.pointSize];
        dialogLabel.text = arabicText;
        NSTimeInterval dialogDuration = [self getDurationAndPlaySpeakerDialogAudioWithKey:key prefix:mainSpeaker.name suffix:@"Arabic"];
        
        dispatch_after(DISPATCH_SECONDS_FROM_NOW(dialogDuration), dispatch_get_current_queue(), ^{
            
            completion();
        });
        
    });
    
}


-(NSMutableArray*)getUnicodesForLetters:(id)arabicLetters{
    NSMutableArray* mutableArabicLettersArray = [[NSMutableArray alloc] init];
    NSMutableArray* arabicUnicodes = [[NSMutableArray alloc] init];
    
    if ([arabicLetters isKindOfClass: [NSMutableString class]]) {
        [mutableArabicLettersArray addObject:arabicLetters];
    } else if ([arabicLetters isKindOfClass: [NSString class]]) {
        [mutableArabicLettersArray addObject:arabicLetters];
    } else if ([arabicLetters isKindOfClass: [NSArray class]]) {
        mutableArabicLettersArray = [arabicLetters mutableCopy];
    } else {
        if (DEBUG_ARABIC_NAME) { NSLog(@"Not sure what class type this is %@",[arabicLetters class]); }
    }
    for (NSString* s in mutableArabicLettersArray) {
        if (DEBUG_ARABIC_NAME) { NSLog(@"Looking up arabic letter: %@",s); }
        NSString* unicodeValue = [[self.arabicLettersByNameDictionary objectForKey:s] objectForKey:@"Isolated"];
        
        if (DEBUG_ARABIC_NAME) { NSLog(@"Got this unicode value from lookup: %@", unicodeValue); }
        if (unicodeValue) {
            [arabicUnicodes addObject:[[self.arabicLettersByNameDictionary objectForKey:s] objectForKey:@"Isolated"]];
        } else {
            if (DEBUG_ARABIC_NAME) { NSLog(@"Letter key %@ was not found in arabicLettersByNameDictionary",s); }
            return nil;
        }
    }
    return arabicUnicodes;
}

-(NSMutableArray*)getUnicodeIndexes:(id)arabicLetters{
    NSMutableArray* mutableArabicLettersArray = [[NSMutableArray alloc] init];
    NSMutableArray* unicodeIndexes = [[NSMutableArray alloc] init];
    NSMutableDictionary* letterIndexHash = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* unicodeLetterIndexHash = [[NSMutableDictionary alloc] init];
    NSString* letterName = [[NSString alloc] init];
    NSString* unicodeLetter = [[NSString alloc] init];
    
    if ([arabicLetters isKindOfClass: [NSMutableString class]]) {
        [mutableArabicLettersArray addObject:arabicLetters];
    } else if ([arabicLetters isKindOfClass: [NSString class]]) {
        [mutableArabicLettersArray addObject:arabicLetters];
    } else if ([arabicLetters isKindOfClass: [NSArray class]]) {
        mutableArabicLettersArray = [arabicLetters mutableCopy];
    } else if ([arabicLetters isKindOfClass: [NSMutableArray class]]) {
        mutableArabicLettersArray = arabicLetters;
    } else {
        if (DEBUG_ARABIC_NAME) { NSLog(@"Not sure what class type this is %@",[arabicLetters class]); }
    }
    
    for (NSUInteger i=0; i < [self.arabicLettersDictionary count]; i++) {
        letterName = [[self.arabicLettersDictionary objectAtIndex:i ] objectForKey:@"Name"];
        unicodeLetter = [[self.arabicLettersDictionary objectAtIndex:i ] objectForKey:@"Isolated"];
        [letterIndexHash setValue:[NSNumber numberWithUnsignedInteger:i] forKey:letterName];
        [unicodeLetterIndexHash setValue:[NSNumber numberWithUnsignedInteger:i] forKey:[unicodeLetter lowercaseString]];
    }
    
    for (NSString* s in mutableArabicLettersArray) {
        if (DEBUG_ARABIC_NAME) { NSLog(@"Looking up arabic letter: %@",s); }
        if ([letterIndexHash objectForKey:s]) {
            [unicodeIndexes addObject: [letterIndexHash objectForKey:s]];
            if (DEBUG_ARABIC_NAME) { NSLog(@"Got this unicode index from lookup: %@", [letterIndexHash objectForKey:s]); }
        } else if ([unicodeLetterIndexHash objectForKey:s]) {
            [unicodeIndexes addObject: [unicodeLetterIndexHash objectForKey:s]];
            if (DEBUG_ARABIC_NAME) { NSLog(@"Got this unicode index from lookup: %@", [unicodeLetterIndexHash objectForKey:s]); }
        } else {
            if (DEBUG_ARABIC_NAME) { NSLog(@"Did NOT find an index for letter %@", s); }
        }
    }
    return unicodeIndexes;
}

- (NSMutableString*)reduceName:(NSMutableString*)arabicName byPatterns:(NSMutableArray*)patterns {
    NSMutableString* lettersToLookup = [[NSMutableString alloc] init];
    NSMutableArray* unicodeLetters = [[NSMutableArray alloc] init];
    BOOL pattern_found = FALSE;
    
    //for each pattern, check if that's in the name and reduce
    for (NSString* p in patterns) {
        if ([arabicName hasPrefix:p]) {
            lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"initial"];
            if (DEBUG_ARABIC_NAME) { NSLog(@"Found prefix %@",lettersToLookup); }
            pattern_found = TRUE;
        } else if ([arabicName hasSuffix:p]) {
            lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"middle"];
            if (DEBUG_ARABIC_NAME) { NSLog(@"Found suffix %@",lettersToLookup); }
            pattern_found = TRUE;
        } else if ([arabicName rangeOfString:p].location != NSNotFound) {
            lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"middle"];
            if (DEBUG_ARABIC_NAME) { NSLog(@"Found pattern %@",lettersToLookup); }
            pattern_found = TRUE;
        } else {
            pattern_found = FALSE;
        }
        
        if(pattern_found) {
            //lookup unicodes for replacement of string arabicName in place
            NSArray* lettersToLookupArray = [lettersToLookup componentsSeparatedByString:@", "];
            NSMutableString* replaceWith = [[NSMutableString alloc] initWithString:@""];
            NSString* temp;

            unicodeLetters = [self getUnicodesForLetters:lettersToLookupArray];
            for (NSString* unicodeLetter in unicodeLetters) {
                NSUInteger unicodeValue;
                [[NSScanner scannerWithString:unicodeLetter] scanHexInt:&unicodeValue];
                unicodeValue = (unichar)unicodeValue;
                
                NSString* str = [NSString stringWithFormat:@"%C", (unichar)unicodeValue];
                [replaceWith appendString:str];
                
            }
            temp = [arabicName stringByReplacingOccurrencesOfString:p
                                                         withString:replaceWith
                                                            options:NULL range:NSMakeRange(0,arabicName.length)];
            arabicName = [temp mutableCopy];
            
        }
    }
    if (DEBUG_ARABIC_NAME) { NSLog(@"Name after reduction: %@", arabicName); }
    
    return arabicName;
}

//Given the name passed in, return an array of arabic letter indexes
- (NSMutableArray*)translatedLetterArrayForEnglishName:(NSString*)name {
    NSMutableString* arabicName = [name mutableCopy];
    NSString* lettersToLookup = [[NSMutableString alloc] init];
    NSMutableArray* unicodeLetters = [[NSMutableArray alloc] init];
    NSMutableArray* unicodeIndexes = [[NSMutableArray alloc] init];
    
    //Step #1 ---- Check if it's a well known name first
    if ((lettersToLookup = [self.knownNamesDictionary objectForKey:[arabicName lowercaseString]])) {
        unicodeIndexes = [self getUnicodeIndexes:[[lettersToLookup componentsSeparatedByString:@", "] mutableCopy]];
        return unicodeIndexes;
    }
    
    //Step #2 ---- Loop through multiple character patterns
    NSMutableArray* patterns = [[NSMutableArray alloc] init];
    for (NSString* key in [self.transliterationDictionary allKeys]) {
        if (key.length > 1) {
            [patterns addObject:key];
        }
    }
    NSMutableString* arabicNameCopy = [arabicName mutableCopy];
    arabicName = [self reduceName:arabicNameCopy byPatterns:patterns ];
    if (DEBUG_ARABIC_NAME) { NSLog(@"Name after multiple character pattern substitution: %@", name); }
    
    
    //Step #3 ---- Loop through each uppercase charater
    [patterns removeAllObjects];
    for (NSString* key in [transliterationDictionary allKeys]) {
        if([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[key characterAtIndex:0]]) {
            [patterns addObject:key];
        }
    }
    arabicNameCopy = [arabicName mutableCopy];
    arabicName = [self reduceName:arabicNameCopy byPatterns:patterns ];
    if (DEBUG_ARABIC_NAME) { NSLog(@"Name after uppercase pattern substitution: %@", name); }
    
    //Step #4 ---- Loop through all single charaters (will repeat but it's ok)
    BOOL pattern_found = FALSE;
    BOOL IS_SUFFIX = FALSE;
    arabicName = [[arabicName lowercaseString] mutableCopy];
    
    [patterns removeAllObjects];
    for (NSString* key in [self.transliterationDictionary allKeys]) {
        if (key.length == 1) {
            [patterns addObject:key];
        }
    }
      //just go through the loop for as many characters are in the name to make sure we've covered them all
    for (NSUInteger times=0; times < arabicName.length; times++) {
        for (NSString* p in patterns) {
            if ([arabicName hasPrefix:p]) {
                lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"initial"];
                if (DEBUG_ARABIC_NAME) { NSLog(@"Found prefix %@",lettersToLookup); }
                pattern_found = TRUE;
            } else if ([arabicName hasSuffix:p]) {
            //an 'e' on the end of a name is usually nothing ... NEEDS TESTING
            if ( [p isEqualToString:@"e"]) {
                NSString* temp = [arabicName substringWithRange:NSMakeRange(arabicName.length-1, arabicName.length)];
                arabicName = [temp mutableCopy];
                pattern_found = FALSE;
                continue;
            }
            if ([p isEqualToString:@"a"] || [p isEqualToString:@"2"] ) {
                lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"final"];
                IS_SUFFIX = TRUE;
            } else {
                lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"middle"];
            }
            if (DEBUG_ARABIC_NAME) { NSLog(@"Found suffix %@",lettersToLookup); }
            pattern_found = TRUE;
        } else if ([arabicName rangeOfString:p].location != NSNotFound) {
                //LEFT OFF HERE - add rules for 'a' and 'e' in the middle of a word before/between non-vowels
                // JULIE - NEED TO DEBUG THIS SECTION WITH 'FARAH' WHICH STRING TO GET LOCATION OF 'A' OR 'E' IN?
                if ([p isEqualToString:@"a"] || [p isEqualToString:@"e"]) {
                    NSUInteger i = [name rangeOfString:p].location;
                    NSCharacterSet* vowels = [NSCharacterSet characterSetWithCharactersInString:@"aeiouAEIOU"];
                
                    if(![vowels characterIsMember:[name characterAtIndex:i-1]] && ![vowels characterIsMember:[name characterAtIndex:i+1]]) {
                    if (DEBUG_ARABIC_NAME) { NSLog(@"Found 'a' or 'e' in between consanants at pos %lu in name %@",(unsigned long)i,name); }
                    i = [arabicName rangeOfString:p].location;
                    if (DEBUG_ARABIC_NAME) { NSLog(@"....and between consanants at pos %lu in arabicName %@ of length(%lu)",(unsigned long)i,arabicName,(unsigned long)arabicName.length); }

                    NSString* temp = [arabicName substringWithRange:NSMakeRange(0,i)];
                    NSString* temp2 = [arabicName substringWithRange:NSMakeRange(i+1, arabicName.length-i-1)];
                    arabicName = [[temp stringByAppendingString:temp2] mutableCopy];
                    pattern_found = FALSE;
                    continue;
                }
                }
                lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"middle"];
                if (DEBUG_ARABIC_NAME) { NSLog(@"Found pattern %@",lettersToLookup); }
                pattern_found = TRUE;
            } else {
                pattern_found = FALSE;
            }
        
            if(pattern_found) {
            //lookup unicodes for replacement of string arabicName in place
            NSArray* lettersToLookupArray = [lettersToLookup componentsSeparatedByString:@", "];
            NSMutableString* replaceWith = [[NSMutableString alloc] initWithString:@""];
            NSString* temp;
            
            unicodeLetters = [self getUnicodesForLetters:lettersToLookupArray];
            for (NSString* unicodeLetter in unicodeLetters) {
                NSUInteger unicodeValue;
                [[NSScanner scannerWithString:unicodeLetter] scanHexInt:&unicodeValue];
                unicodeValue = (unichar)unicodeValue;
                
                NSString* str = [NSString stringWithFormat:@"%C", (unichar)unicodeValue];
                [replaceWith appendString:str];
                
            }
            //if this is a [single character] suffix, then only replace that occurance
            if (IS_SUFFIX) {
                NSLog(@"Character at index %u is %C", arabicName.length-2, (unichar)[arabicName characterAtIndex:arabicName.length-2]);
                NSLog(@"Character at index %u is %C", arabicName.length-1, (unichar)[arabicName characterAtIndex:arabicName.length-1]);
                temp = [arabicName stringByReplacingCharactersInRange:NSMakeRange(arabicName.length-2,arabicName.length-1) withString:replaceWith];
            } else {
                temp = [arabicName stringByReplacingOccurrencesOfString:p
                                                         withString:replaceWith
                                                            options:NULL range:NSMakeRange(0,arabicName.length)];
            }
            arabicName = [temp mutableCopy];
            
        }
        }
    }
    if (DEBUG_ARABIC_NAME) { NSLog(@"Name after single character substitution: %@", arabicName); }
    
    NSMutableArray* arabicArray = [[NSMutableArray alloc] init];
    for (NSUInteger i=0; i < arabicName.length; i++) {
        unichar a = [arabicName characterAtIndex:i];
        [arabicArray addObject:[NSString stringWithFormat:@"%04x", a]];
        if (DEBUG_ARABIC_NAME) { NSLog(@"Arabic letter codes: %04x", a); }
    }
    return [self getUnicodeIndexes:arabicArray];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
