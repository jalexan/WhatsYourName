//
//  ButtonExpander.h
//  whatsyourname
//
//  Created by Julie Alexan on 9/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonExpander : UIButton <UIGestureRecognizerDelegate>

-(void)expandableButtonPressed;

@property(nonatomic,strong) UIButton *expandableButton;
@property(nonatomic,strong) NSArray *childButtonsArray;

@end
