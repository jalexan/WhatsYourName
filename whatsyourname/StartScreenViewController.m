//
//  StartScreenViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 6/25/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "StartScreenViewController.h"
#import "LetterGameViewController.h"
#import "NameGameViewController.h"
#import "NameSpellViewController.h"
#import "AlphabetViewController.h"
#import "GameUIButton.h"

@interface StartScreenViewController () {
    IBOutlet GameUIButton* bookLinkButton;
    IBOutlet GameUIButton* creditsButton;
    IBOutlet GameUIButton* creditsBackButton;
    IBOutlet GameUIButton* moreGamesButton;
    IBOutlet GameUIButton* playButton;
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
        creditsScreen.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
    }
    creditsScreen.hidden = NO;
    UILabel* creditSectionLabel;
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:[NSString stringWithFormat:@"Credits"] ofType:@"plist"];
    NSArray *credits = [[NSArray alloc] initWithContentsOfFile:plistPath];
    BOOL is_heading = NO;
    NSInteger x_pos = 0;
    NSInteger y_pos = 250;
    NSInteger font_size = 14;
    UIColor *label_bg_color = [UIColor clearColor];
    
    for (NSString *credit in credits) {
        if ([credit isEqualToString:@""]) {  //if the credit is a blank, then the next one is a heading
            is_heading = YES;
            y_pos += 25;
            continue;
        }
        if (is_heading) {
            //change font to smaller size for heading
            is_heading = NO;
            font_size = 20;
        } else {
            //use this default font size
            font_size = 24;
        }
        creditSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x_pos, y_pos, creditsScreen.frame.size.width, 20)];
        creditSectionLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:font_size];
        creditSectionLabel.textColor = [UIColor whiteColor];
        creditSectionLabel.shadowColor = [UIColor blackColor];
        creditSectionLabel.shadowOffset = CGSizeMake(2.0f, 2.0f);
        creditSectionLabel.text = credit;
        creditSectionLabel.textAlignment = NSTextAlignmentCenter;
        creditSectionLabel.backgroundColor = label_bg_color;
        [creditsScreen addSubview:creditSectionLabel];
        y_pos += 25;
    }
    
    [self.view addSubview:creditsBackButton];
    [self.view addSubview:creditsScreen];
    
    [UIView animateWithDuration:[credits count]*0.75 animations:^{
        creditsScreen.contentOffset = CGPointMake(0, y_pos);
    }];
    
    UIImageView* flag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Resource/egy_flag.png"]];
    flag.frame = CGRectMake((creditsScreen.frame.size.width/2) - (flag.image.size.width/2), y_pos, flag.image.size.width, flag.image.size.height);
    [creditsScreen addSubview:flag];
    creditsScreen.contentSize = CGSizeMake(self.view.frame.size.width, flag.bottom + 50);
    
    [creditsBackButton.superview bringSubviewToFront:creditsBackButton];
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
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(viewControllerPopped:)
     name:kPopViewControllerNotification
     object:nil
     ];
    
    [self setupStartScreenButtons];
    
    NSTimeInterval delay = DEBUG_MODE ? 0 : 1;
        
    [self performSelector:@selector(showButtons) withObject:nil afterDelay:delay];
}

- (void)viewControllerPopped:(id)theObject {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    for (UIViewController* vc in self.navigationController.viewControllers) {
        if ([LetterGameViewController class] == [[theObject object] class]) {
            
            LetterGameViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"LetterGameViewController"];
            [self.navigationController pushViewController:vc animated:NO];
            
            break;
        }
        else if ([NameGameViewController class] == [[theObject object] class]) {
            NameGameViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"NameGameViewController"];
            [self.navigationController pushViewController:vc animated:NO];
            
            break;
        }
        else if ([NameSpellViewController class] == [[theObject object] class]) {
            NameSpellViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"NameSpellViewController"];
            [self.navigationController pushViewController:vc animated:NO];
            
            break;
        }
        else if ([AlphabetViewController class] == [[theObject object] class]) {
            AlphabetViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"AlphabetViewController"];
            [self.navigationController pushViewController:vc animated:NO];
            
            break;
        }


    }
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
