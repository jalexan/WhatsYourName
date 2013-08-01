//
//  GameWebViewController.m
//  whatsyourname
//
//  Created by Richard Nguyen on 7/27/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "GameWebViewController.h"

static BOOL NIIsPad(void) {
#ifdef UI_USER_INTERFACE_IDIOM
    static NSInteger isPad = -1;
    if (isPad < 0) {
        isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    }
    return isPad > 0;
#else
    return NO;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface GameWebViewController ()

@end


@implementation GameWebViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)releaseAllSubviews {
    _webView.delegate = nil;
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [self releaseAllSubviews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        
        
    }
    return self;
}

- (id)init {
    self = [self initWithNibName:nil bundle:nil];
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private

- (IBAction)homeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)backAction {
    [_webView goBack];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)forwardAction {
    [_webView goForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshAction {
    [_webView reload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopAction {
    [_webView stopLoading];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    {
        UIScrollView *subScrollView;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
            for (UIView *subview in [_webView subviews]) {
                if ([[subview.class description] isEqualToString:@"UIScrollView"]) {
                    subScrollView = (UIScrollView *)subview;
                }
            }
        }else {
            subScrollView = (UIScrollView *)[_webView scrollView];
        }
        subScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self releaseAllSubviews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self updateToolbarWithOrientation:self.interfaceOrientation];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
    // If the browser launched the media player, it steals the key window and never gives it
    // back, so this is a way to try and fix that.
    [self.view.window makeKeyWindow];
    
    [super viewWillDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (NIIsPad()) {
        return YES;
    } else {
        switch (interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return YES;
            default:
                return NO;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    //[self updateToolbarWithOrientation:toInterfaceOrientation];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    _loadingURL = [request.mainDocumentURL copy];
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidStartLoad:(UIWebView*)webView {
    
    self.title = NSLocalizedString(@"Loading...", @"");

    [_spinner startAnimating];

    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView*)webView {
    
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [_spinner stopAnimating];
    
    _backButton.enabled = [_webView canGoBack];
    _forwardButton.enabled = [_webView canGoForward];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    [self webViewDidFinishLoad:webView];
    
    [_spinner stopAnimating];
}


#pragma mark -
#pragma mark Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)URL {
    return _loadingURL ? _loadingURL : _webView.request.mainDocumentURL;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURL:(NSURL*)URL {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    [self openRequest:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openRequest:(NSURLRequest*)request {
    // The view must be loaded before you call this method.
    // NIDASSERT([self isViewLoaded]);
    [self view];
    [_webView loadRequest:request];
}

@end
