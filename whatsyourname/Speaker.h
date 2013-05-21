//
//  Character.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

@interface Speaker : NSObject {
    
}
- (id) initWithName:(NSString*)theName;

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSDictionary* dialogDictionary;
@property (nonatomic, readonly) NSArray* letterIndexArray;

- (NSDictionary*)dialogForKey:(NSString*)key;

@end
