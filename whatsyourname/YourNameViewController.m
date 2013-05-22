//
//  YourNameViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/21/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "YourNameViewController.h"

@interface YourNameViewController () {
    NSDictionary* yourNameDialogDictionary;
}

@end

@implementation YourNameViewController


- (void)viewDidLoad
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:[NSString stringWithFormat:@"Resource/YourNameDialog"] ofType:@"plist"];
    
    yourNameDialogDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];


    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    goodByeButton.hidden = YES;
	nameTextField.hidden = YES;
    restartButton.hidden = YES;
    
    [self displayDialogTextWithKey:@"Now" completion:^() {
        
        [self displayDialogTextWithKey:@"Whats" completion:^() {
            
            
            [self displayDialogTextWithKey:@"Write" completion:^() {
                
                nameTextField.hidden = NO;
                
            }];
            
            
        }];
        
    }];
    
}


- (void)displayGreetingWithName:(NSString*)name {
 
    NSString* hello = [NSString stringWithFormat:@"Nice to meet you %@!",name];
    [self displayEnglishText:hello arabicText:@"(arabic text)" duration:3 completion:^() {
        
        [self displayDialogTextWithKey:@"Another" completion:^() {
            
            nameTextField.hidden = NO;
            goodByeButton.hidden = NO;
           
        }];
        
    }];
    
}

- (void)displayDialogTextWithKey:(NSString*)key completion:(void(^)())completion {
    
    NSDictionary* dialogDictionary = [yourNameDialogDictionary objectForKey:key];
    if (!dialogDictionary)
        return;
    
    NSTimeInterval duration = [[dialogDictionary objectForKey:@"Duration"] floatValue];
    
    NSString* text = [dialogDictionary objectForKey:@"English"];
    NSString* arabicText = [dialogDictionary objectForKey:@"Arabic"];

    [self displayEnglishText:text arabicText:arabicText duration:duration completion:completion];
}


- (void)displayEnglishText:(NSString*)englishText arabicText:(NSString*)arabicText duration:(NSTimeInterval)duration completion:(void(^)())completion {
    dialogLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:28];
    dialogLabel.text = englishText;
    
    dialogLabel.alpha = .99;
    
    [UIView animateWithDuration: duration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         dialogLabel.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                         dialogLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:28];
                         dialogLabel.text = arabicText;
                         dialogLabel.alpha = .99;
                         
                         [UIView animateWithDuration: duration
                                               delay: 0.0
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              dialogLabel.alpha = 1;
                                          }
                                          completion:^(BOOL finished){
                                              
                                              completion();
                                          }];
                         
                         
                     }];
    
}

- (IBAction)goodByeButtonTouched:(id)sender {
    nameTextField.hidden = YES;
    goodByeButton.hidden = YES;
    [self displayDialogTextWithKey:@"Bye" completion:^() {
        
        restartButton.hidden = NO;
        
    }];
    
}

- (IBAction)restartButtonTouched:(id)sender {
    [self performSegueWithIdentifier:@"RestartSegue" sender:self];
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {    
    [textField resignFirstResponder];
    
    if (textField.text.length>0) {
        [self displayGreetingWithName:textField.text];
    }
    
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [nameTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
