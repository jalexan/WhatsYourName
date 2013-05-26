//
//  Tile.h
//  whatsyourname
//
//  Created by Richard Nguyen on 5/12/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

@interface ArabicLetter : NSObject {
    
}
- (id) initWithLetterIndex:(NSUInteger)index;
@property (nonatomic, readonly) NSDictionary* letterDictionary;
@property (nonatomic, readonly) NSUInteger letterIndex;
@property (nonatomic, readonly) NSString* letterName;
@property (nonatomic, assign) int slotPosition;
@property(nonatomic, assign) BOOL isInCorrectSlot;
@end
