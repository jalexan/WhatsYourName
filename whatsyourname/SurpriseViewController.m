//
//  SurpriseViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/21/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "SurpriseViewController.h"
#import "NameGameViewController.h"

#define SURPRISE_DELAY 2.0

@interface SurpriseViewController ()

@end

@implementation SurpriseViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)segueAfterDelay {
    [self performSegueWithIdentifier:@"YourNameSegue" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    question.image = [UIImage imageNamed:@"Resource/question_mark.png"];
    
    [self performSelector:@selector(segueAfterDelay) withObject:nil afterDelay:SURPRISE_DELAY];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
