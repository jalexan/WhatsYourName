//
//  ChooseLevelViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 8/5/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "ChooseLevelViewController.h"
#import "GameUIButton.h"

@interface ChooseLevelViewController () {
    BOOL isLevel4Unlocked;
    
    IBOutlet UIButton* backButton;

    //IBOutlet UIButton* Level1Button;
    IBOutlet UIButton* AlphabetLevelButton;

    IBOutlet GameUIButton* level4GameUIButton;
    IBOutlet UIImageView* lockImageView;
}

- (IBAction)backButtonTouched:(id)sender;
- (IBAction)Level4ButtonTouched:(id)sender;
- (IBAction)AlphabetLevelButtonTouched:(id)sender;



@end

@implementation ChooseLevelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Level4Unlocked"] == YES) {
        isLevel4Unlocked = YES;
    }
    
    if (isLevel4Unlocked) {
        level4GameUIButton.hidden = NO;
        
    }
    else {
        level4GameUIButton.hidden = YES;
    }
    lockImageView.hidden = !level4GameUIButton.hidden;
    
}

- (IBAction)backButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)Level4ButtonTouched:(id)sender {
    if (isLevel4Unlocked) {
        
    }
    
}

- (IBAction)AlphabetLevelButtonTouched:(id)sender {
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
