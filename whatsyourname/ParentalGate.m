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
   // UIAlertView* alertView;
    UIAlertController *alertController;
    NSUInteger questionAnswer;
}
@end


@implementation ParentalGate

- (id)initWithAnswerBlock:(AnswerBlock)theAnswerBlock
{
    self = [super init];
    if (self) {
        answerBlock = theAnswerBlock;
        
        NSUInteger a = (arc4random() % 8)+2;
        NSUInteger b = (arc4random() % 8)+2;
        questionAnswer = a * b;
        NSString *alertTitle = @"Grownups only!";
        NSString* question = [NSString stringWithFormat:@"What is %lu * %lu",a,b];
        /*
        alertView = [[UIAlertView alloc] initWithTitle:nil message:question delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter",nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
         */
        
        //NEW
        alertController = [UIAlertController alertControllerWithTitle:alertTitle message:question preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"enter your answer";
            // customize the text field
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            // Handle Cancel button tap
            answerBlock(NO);
        }];

        UIAlertAction *enterAction = [UIAlertAction actionWithTitle:@"Enter" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            UITextField *textField = alertController.textFields.firstObject;

            // Handle Enter button tap
            
                    NSString* answer = textField.text;
                    NSLog(@"%@", answer);
                    
                    if ([answer integerValue]==questionAnswer) {
                        answerBlock(YES);
                    }
                    else {
                        answerBlock(NO);
                    }
        }];

        [alertController addAction:cancelAction];
        [alertController addAction:enterAction];


        
        
    }
    return self;
}
/*
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
*/


- (void)validateIfUserIsParentforVC:(UIViewController*)vc{
   // [alertView show];
    //[[alertView textFieldAtIndex:0] resignFirstResponder];
    [vc presentViewController:alertController animated:YES completion:nil];

}


@end
