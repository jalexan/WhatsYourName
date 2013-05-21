//
//  Character.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "Speaker.h"
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

- (NSDictionary*)dialogForKey:(NSString*)key {
    return [dialogDictionary objectForKey:key];
}


@end
