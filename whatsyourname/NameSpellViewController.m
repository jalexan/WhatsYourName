//
//  NameSpellViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "NameSpellViewController.h"
#import "NameGameViewController.h"
#import "ArabicLetter.h"
#import "ArabicLetterImageView.h"
#import "SpeakerList.h"

#define DEBUG_ARABIC_NAME 1

@interface NameSpellViewController () {
    NSDictionary* yourNameDialogDictionary;
    Speaker* mainSpeaker;
    NSMutableArray* arabicLettersArray;
    NSMutableArray* letterImageViewArray;
    NSString* translatedArabicName;
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
    
    
    arabicSpellLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:64];
    arabicSpellLabel.adjustsFontSizeToFitWidth = YES;
    arabicSpellLabel.minimumScaleFactor = 0.5;

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
                NSArray* viewControllers = self.navigationController.viewControllers;
                if (viewControllers.count>1) {
                    NameGameViewController* vc = (NameGameViewController*)viewControllers[viewControllers.count-2];
                    vc.playerNameArabic = translatedArabicName;
                }
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
      //  if (DEBUG_ARABIC_NAME) { NSLog(@"Looking up arabic letter: %@",s); }
        NSString* unicodeValue = [[self.arabicLettersByNameDictionary objectForKey:s] objectForKey:@"Isolated"];
        
      //  if (DEBUG_ARABIC_NAME) { NSLog(@"Got this unicode value from lookup: %@", unicodeValue); }
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
      //  if (DEBUG_ARABIC_NAME) { NSLog(@"Looking up arabic letter: %@",s); }
        if ([letterIndexHash objectForKey:s]) {
            [unicodeIndexes addObject: [letterIndexHash objectForKey:s]];
        //    if (DEBUG_ARABIC_NAME) { NSLog(@"Got this unicode index from lookup: %@", [letterIndexHash objectForKey:s]); }
        } else if ([unicodeLetterIndexHash objectForKey:s]) {
            [unicodeIndexes addObject: [unicodeLetterIndexHash objectForKey:s]];
      //      if (DEBUG_ARABIC_NAME) { NSLog(@"Got this unicode index from lookup: %@", [unicodeLetterIndexHash objectForKey:s]); }
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
    NSInteger position;
    
    //for each pattern, check if that's in the name and reduce
    for (NSString* p in patterns) {
        if ([arabicName hasPrefix:p]) {
            position = 0;
            lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"initial"];
            if (DEBUG_ARABIC_NAME) { NSLog(@"Found prefix %@",lettersToLookup); }
            pattern_found = TRUE;
        } else if ([arabicName hasSuffix:p]) {
            position = [arabicName rangeOfString:p].location;
            lettersToLookup = [[transliterationDictionary objectForKey:p] objectForKey:@"middle"];
            if (DEBUG_ARABIC_NAME) { NSLog(@"Found suffix %@",lettersToLookup); }
            pattern_found = TRUE;
        } else if ([arabicName rangeOfString:p].location != NSNotFound) {
            position = [arabicName rangeOfString:p].location;
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
                                                            options:NULL range:NSMakeRange(position,p.length)];
            arabicName = [temp mutableCopy];
        }
    }
    if (DEBUG_ARABIC_NAME) { NSLog(@"  *Name after reduction: %@", arabicName); }
    
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
    arabicName = [[arabicName lowercaseString] mutableCopy];
    
    [patterns removeAllObjects];
    for (NSString* key in [self.transliterationDictionary allKeys]) {
        if (key.length == 1) {
            [patterns addObject:key];
        }
    }
    
    //LEFT OFF HERE - just need to add the part about 'a' or 'e' in the middle of the string
    NSString* c;
    BOOL middle_vowel_found = FALSE;
    
    for (NSInteger i=0; i < arabicName.length; i++) {
        c = [NSString stringWithFormat:@"%C",[arabicName characterAtIndex:i]];
        if (i==0) { //this is the first letter
            lettersToLookup = [[transliterationDictionary objectForKey:c] objectForKey:@"initial"];
            if (lettersToLookup) {
                if (DEBUG_ARABIC_NAME) { NSLog(@"Found prefix %@",lettersToLookup); }
                pattern_found = TRUE;
            } else {
                if (DEBUG_ARABIC_NAME) { NSLog(@"Found prefix %@ BUT couldn't get the letter to lookup",lettersToLookup);
                    pattern_found = FALSE;
                }            }
        } else if (i > 0 && i < arabicName.length-1) { //this is a middle letter
            lettersToLookup = [[transliterationDictionary objectForKey:c] objectForKey:@"middle"];
            if (lettersToLookup) {
                if (DEBUG_ARABIC_NAME) { NSLog(@"Found middle %@",lettersToLookup); }
                pattern_found = TRUE;
            } else {
                if (DEBUG_ARABIC_NAME) { NSLog(@"Found middle %@ BUT couldn't get the letter to lookup",lettersToLookup);
                    pattern_found = FALSE;
                }            }
            if ([c isEqualToString:@"a"] || [c isEqualToString:@"e"]) {
                middle_vowel_found = TRUE;
            }
        } else {  //this is the last letter
            if ([[transliterationDictionary objectForKey:c] objectForKey:@"final"]) {
                lettersToLookup = [[transliterationDictionary objectForKey:c] objectForKey:@"final"];
            } else {
                lettersToLookup = [[transliterationDictionary objectForKey:c] objectForKey:@"middle"];
            }
            if (lettersToLookup) {
                if (DEBUG_ARABIC_NAME) { NSLog(@"Found suffix %@",lettersToLookup); }
                pattern_found = TRUE;
            } else {
                // if (DEBUG_ARABIC_NAME) { NSLog(@"Found suffix %@ BUT couldn't get the letter to lookup",lettersToLookup);
                pattern_found = FALSE;
            }
        }
        if (middle_vowel_found) {
            //LEFT OFF HERE
            //maybe remove it and if so,
            //pattern_found = FALSE;
        }
        if (pattern_found) {
            //lookup unicodes for replacement of string arabicName in place
            NSArray* lettersToLookupArray = [lettersToLookup componentsSeparatedByString:@", "];
            unicodeLetters = [self getUnicodesForLetters:lettersToLookupArray];
            for (NSString* unicodeLetter in unicodeLetters) {
                
                NSUInteger unicodeValue;
                [[NSScanner scannerWithString:unicodeLetter] scanHexInt:&unicodeValue];
                NSString* temp;
                NSString* replaceWith = [NSString stringWithFormat:@"%C", (unichar)unicodeValue];
                temp = [arabicName stringByReplacingCharactersInRange:NSMakeRange(i,1) withString:replaceWith];
                
                arabicName = [temp mutableCopy];
            }
        }
        
    }
    if (DEBUG_ARABIC_NAME) { NSLog(@"Name after single character substitution: %@", arabicName); }
    
    
    translatedArabicName = arabicName;
    NSMutableArray* arabicArray = [[NSMutableArray alloc] init];
    for (NSUInteger i=0; i < arabicName.length; i++) {
        unichar a = [arabicName characterAtIndex:i];
        [arabicArray addObject:[NSString stringWithFormat:@"%04x", a]];
       // if (DEBUG_ARABIC_NAME) { NSLog(@"Arabic letter codes: %04x", a); }
    }
    return [self getUnicodeIndexes:arabicArray];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
