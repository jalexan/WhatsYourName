//
//  Speakers.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/22/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "SpeakerList.h"
#import "Singleton.h"



@interface SpeakerList () {
    NSMutableArray* speakerArray;
}

@end

@implementation SpeakerList
SYNTHESIZE_SINGLETON_FOR_CLASS(SpeakerList)
@synthesize speakerArray;
@synthesize numberOfSpeakers;

- (id)init {
	if ((self = [super init])) {
     
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* plistPath = [bundle pathForResource:@"Speakers" ofType:@"plist"];
        NSArray* speakerPlistArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
        
        speakerArray = [NSMutableArray arrayWithCapacity:[speakerPlistArray count]];
        for (NSString* speakerName in speakerPlistArray) {
            Speaker* aSpeaker = [[Speaker alloc] initWithName:speakerName];
            
            [speakerArray addObject:aSpeaker];
        }

        
	}
	return self;
}

- (BOOL)isLastSpeaker:(Speaker*)speaker {
    if (speaker == [speakerArray lastObject]) {
        return YES;
    }
    else
        return NO;
}


- (NSUInteger)numberOfSpeakers {
    return [speakerArray count];
}

@end
