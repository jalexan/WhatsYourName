//
//  ParentalGate.m
//  whatsyourname
//
//  Created by Richard Nguyen on 10/13/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ParentalGate.h"

@interface ParentalGate () {
    AnswerBlock answerBlock;
    UIAlertView* alertView;
    NSUInteger questionAnswer;
}
@end


@implementation ParentalGate

- (id)initWithAnswerBlock:(AnswerBlock)theAnswerBlock
{
    self = [super init];
    if (self) {
        answerBlock = theAnswerBlock;
        
        NSUInteger a = (arc4random() % 9)+1;
        NSUInteger b = (arc4random() % 9)+1;
        questionAnswer = a * b;
        NSString* question = [NSString stringWithFormat:@"Parent Zone! What is %d * %d?",a,b];
        alertView = [[UIAlertView alloc] initWithTitle:nil message:question delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter",nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
        
        
    }
    return self;
}

-(void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString* answer = [theAlertView textFieldAtIndex:0].text;
        NSLog(@"%@", answer);
        
        if ([answer integerValue]==questionAnswer) {
            answerBlock(YES);
        }
        else {
            answerBlock(NO);
        }
        
    }
}

- (void)validateIfUserIsParent {
    [alertView show];
    //[[alertView textFieldAtIndex:0] resignFirstResponder];
}


@end
