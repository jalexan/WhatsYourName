//
//  Speakers.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/22/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "Speakers.h"
#import "Singleton.h"

@implementation Speakers

SYNTHESIZE_SINGLETON_FOR_CLASS(Speakers)
@synthesize test;

- (id)init {
	if ((self = [super init])) {
        
	}
	return self;
}



@end
