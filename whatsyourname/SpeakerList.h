//
//  Speakers.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/22/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Speaker.h"

@interface SpeakerList : NSObject {
    
}
+ (SpeakerList*)sharedInstance;

@property (nonatomic, readonly) NSArray* speakerArray;
@property (nonatomic, readonly) NSUInteger numberOfSpeakers;

- (BOOL)isLastSpeaker:(Speaker*)speaker;
@end
