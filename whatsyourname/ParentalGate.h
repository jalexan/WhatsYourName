//
//  ParentalGate.h
//  whatsyourname
//
//  Created by Richard Nguyen on 10/13/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AnswerBlock)(BOOL isCorrectAnswer);

@interface ParentalGate : NSObject

- (id)initWithAnswerBlock:(AnswerBlock)theAnswerBlock;
- (void)validateIfUserIsParent;

@end

