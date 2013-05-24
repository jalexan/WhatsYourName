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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSelector:@selector(segueAfterDelay) withObject:nil afterDelay:2];

}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note {
    
    
    CGRect tempBounds = [[UIScreen mainScreen] bounds];
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    /*
     if (orientation==UIInterfaceOrientationLandscapeLeft || orientation==UIInterfaceOrientationLandscapeRight)
     {
     
     }
     else {
     
     }
     */
    
    //Check for 4inch screen
    if (tempBounds.size.height==568 || tempBounds.size.width==568) {
        CGRect r = self.view.frame;
        //r.size = CGSizeMake(320, 480);
        r.origin = CGPointMake(44, 0);
        self.view.frame = r;
    }
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)segueAfterDelay {
    [self performSegueWithIdentifier:@"YourNameSegue" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
