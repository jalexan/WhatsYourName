//
//  ButtonExpander.m
//  whatsyourname
//
//  Created by Julie Alexan on 9/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ButtonExpander.h"

# define EXPAND_DURATION 0.5


@implementation ButtonExpander {
    UITapGestureRecognizer *gr;
    BOOL isExpanded;
    float lastYPosition;
}

@synthesize expandableButton;
@synthesize childButtonsArray;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandableButtonPressed)];
        [self addGestureRecognizer:gr];
        self.clipsToBounds = NO;
        [self setUserInteractionEnabled:YES];
    
        isExpanded = NO;
    }
    
    return self;
}

-(void)setChildButtonsArray:(NSArray *)c{
    childButtonsArray = c;
    // Set origins of child buttons
    UIButton *button;
    for (NSInteger i=0; i<[childButtonsArray count]; i++) {
        button = [childButtonsArray objectAtIndex:i];
        [button setFrame:CGRectMake(self.frame.size.width/2 - button.frame.size.width/2, 2, button.frame.size.width, button.frame.size.height)];

        [self addSubview:button];
        [self sendSubviewToBack:button];
        button.hidden = YES;
        [button setUserInteractionEnabled:NO];
    }
}

-(void)expandableButtonPressed {
    UIButton *button;
    float spaceBetweenButtons = 15;
    float y;
    
    if (isExpanded) {
        // collapse child icons
        y = lastYPosition;
        for (NSInteger i=[self.childButtonsArray count]-1; i>=0; i--) {
            if ([[self.childButtonsArray objectAtIndex:i] isKindOfClass:[UIButton class]]) {
                button = [self.childButtonsArray objectAtIndex:i];

                [button setUserInteractionEnabled:NO];
                
                y = y + button.frame.size.height + spaceBetweenButtons;

                [UIView animateWithDuration: EXPAND_DURATION
                                      delay: 0.0
                                    options: UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     
                                     [button setFrame:CGRectMake(button.frame.origin.x, 2,
                                                                 button.frame.size.width, button.frame.size.height)];
                                     
                                 }
                                 completion:^(BOOL finished){
                                     NSLog(@"");
                                 }];
                    
            }
        }
        isExpanded = NO;
        
    } else {
        // expand child icons
        y=0;
        for (NSInteger i=0; i < [self.childButtonsArray count]; i++) {
            if ([[self.childButtonsArray objectAtIndex:i] isKindOfClass:[UIButton class]]) {
                button = [self.childButtonsArray objectAtIndex:i];
                button.hidden = NO;
                [button setUserInteractionEnabled:YES];
                    
                y = y - button.frame.size.height - spaceBetweenButtons,
             
                [UIView animateWithDuration: EXPAND_DURATION
                                      delay: 0.0
                                    options: UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     
                                     [button setFrame:CGRectMake(button.frame.origin.x, y,
                                                                 button.frame.size.width, button.frame.size.height)];
                                     
                                 }
                                 completion:^(BOOL finished){
                                     NSLog(@"");
                                 }];
               
            }
        }
        lastYPosition = y;
        isExpanded = YES;
    }

}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    // make sure this point is in the subview (a child button)
    BOOL pointDetected = NO;
    for (NSInteger i=0; i< [childButtonsArray count]; i++) {

        UIButton *button = [childButtonsArray objectAtIndex:i];
        pointDetected = CGRectContainsPoint(button.frame, point);
        if (pointDetected) return YES;
    }
    if (!pointDetected) {
        return [super pointInside:point withEvent:event];
    }
    
    return pointDetected;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
