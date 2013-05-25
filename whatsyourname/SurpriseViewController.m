//
//  SurpriseViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/21/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "SurpriseViewController.h"
#import "YourNameViewController.h"

@interface SurpriseViewController ()

@end

@implementation SurpriseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)segueAfterDelay {
    [self performSegueWithIdentifier:@"YourNameSegue" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self performSelector:@selector(segueAfterDelay) withObject:nil afterDelay:4];

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
