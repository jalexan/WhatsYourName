//
//  ButtonExpander.m
//  whatsyourname
//
//  Created by Julie Alexan on 9/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ButtonExpander.h"

# define ANIMATION_DURATION 0.5


@implementation ButtonExpander {
    UITapGestureRecognizer *gr;
    BOOL isExpanded;
}

@synthesize expandableButton;
@synthesize childButtonsArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandableButtonPressed)];
        [self addGestureRecognizer:gr];
        self.clipsToBounds = NO;
        
        
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
        [button setFrame:CGRectMake(self.frame.size.width/2 - button.frame.size.width/2, self.frame.origin.y, button.frame.size.width, button.frame.size.height)];
        [self addSubview:button];
        [self sendSubviewToBack:button];
        button.hidden = YES;
        [button setUserInteractionEnabled:NO];
    }
}

-(void)expandableButtonPressed {
    UIButton *button;
    float spaceBetweenButtons = 15;
    float y=0;
    
    if (isExpanded) {
        // collapse
        for (NSInteger i=0; i < [self.childButtonsArray count]; i++) {
            if ([[self.childButtonsArray objectAtIndex:i] isKindOfClass:[UIButton class]]) {
                button = [self.childButtonsArray objectAtIndex:i];
                [button setFrame:CGRectMake(self.frame.size.width/2 - button.frame.size.width/2, self.frame.origin.y,
                                            button.frame.size.width, button.frame.size.height)];
                button.hidden = YES;
                [button setUserInteractionEnabled:NO];
                
                //JULIE - FIX THIS CALCULATION TO ANIMATE BACK DOWN
                y = y + button.frame.size.height + spaceBetweenButtons;

                [UIView animateWithDuration:(ANIMATION_DURATION) animations:^{
                    [button setFrame:CGRectMake(button.frame.origin.x, y,
                                                button.frame.size.width, button.frame.size.height)];
                }];
                
            }
        }
        isExpanded = NO;
        
    } else {
        // last button in array animates first to be furthest out
        for (NSInteger i=0; i < [self.childButtonsArray count]; i++) {
            if ([[self.childButtonsArray objectAtIndex:i] isKindOfClass:[UIButton class]]) {
                button = [self.childButtonsArray objectAtIndex:i];
                button.hidden = NO;
                [button setUserInteractionEnabled:YES];
                y = y - button.frame.size.height - spaceBetweenButtons;
                    
                [UIView animateWithDuration:(ANIMATION_DURATION) animations:^{
                    [button setFrame:CGRectMake(button.frame.origin.x, y,
                                                button.frame.size.width, button.frame.size.height)];
                }];
                
            }
        }
        isExpanded = YES;
    }

}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    //JULIE
    //need to make sure this point is in the subview (a child button)...google
    return YES;
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
