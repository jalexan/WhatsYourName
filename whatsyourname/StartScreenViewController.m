//
//  StartScreenViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/25/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "StartScreenViewController.h"

@interface StartScreenViewController () {
    IBOutlet UIButton* bookLinkButton;
    IBOutlet UIButton* creditsButton;
    IBOutlet UIButton* creditsBackButton;
    IBOutlet UIButton* moreGamesButton;
    IBOutlet UIButton* playButton;
    UIScrollView* creditsScreen;

}
-(IBAction)bookLinkButtonTouched:(id)sender;
-(IBAction)creditsButtonTouched:(id)sender;
-(IBAction)creditsBackButtonTouched:(id)sender;
@end

@implementation StartScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)bookLinkButtonTouched:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://noliafasolia.com/books"]];

}

-(IBAction)creditsBackButtonTouched:(id)sender {
    creditsBackButton.hidden = YES;
    [creditsScreen setContentOffset:CGPointMake(0, 0)];
    creditsScreen.hidden = YES;
    [self showButtons];
}

-(IBAction)creditsButtonTouched:(id)sender {
    bookLinkButton.hidden = YES;
    creditsButton.hidden = YES;
    moreGamesButton.hidden = YES;
    playButton.hidden = YES;
    creditsBackButton.hidden = NO;

    if (!creditsScreen) {
        creditsScreen = [[UIScrollView alloc] init];
        creditsScreen.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height - 50);
        creditsScreen.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2);
    }
    creditsScreen.hidden = NO;
    UILabel* sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, creditsScreen.frame.size.width - 200, 50)];

    
    sectionTitle.textAlignment = NSTextAlignmentCenter;
    sectionTitle.backgroundColor = [UIColor clearColor];
    [creditsScreen addSubview:sectionTitle];
    [self.view addSubview:creditsBackButton];
    [self.view addSubview:creditsScreen];
    
    [UIView animateWithDuration:10 animations:^{
        creditsScreen.contentOffset = CGPointMake(0, creditsScreen.contentSize.height);
        
    }];
}

-(void)setupStartScreenButtons {
    bookLinkButton.hidden = YES;
    creditsButton.hidden = YES;
    creditsBackButton.hidden = YES;
    moreGamesButton.hidden = YES;
    playButton.hidden = YES;
    playButton.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupStartScreenButtons];
    
    NSTimeInterval delay = DEBUG_MODE ? 0 : 5;
        
    [self performSelector:@selector(showButtons) withObject:nil afterDelay:delay];
}

-(void)showButtons {
    bookLinkButton.hidden = NO;
    creditsButton.hidden = NO;
    moreGamesButton.hidden = NO;
    playButton.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
