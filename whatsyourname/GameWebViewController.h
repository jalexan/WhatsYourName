//
//  GameWebViewController.h
//  whatsyourname
//
//  Created by Richard Nguyen on 7/27/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface GameWebViewController : UIViewController <WKNavigationDelegate,UIActionSheetDelegate > {
IBOutlet WKWebView*        _webView;

IBOutlet UIButton*  _backButton;
IBOutlet UIButton*  _forwardButton;
IBOutlet UIButton*  _refreshButton;
IBOutlet UIButton* _homeButton;
//UIButton*  _stopButton;

IBOutlet UIActivityIndicatorView*  _spinner;

NSURL*            _loadingURL;
}
- (IBAction)backAction;
- (IBAction)forwardAction;
- (IBAction)refreshAction;
- (IBAction)homeAction;

/**
 * The current web view URL.
 *
 * If the web view is currently loading a URL then the loading URL is returned instead.
 */
- (NSURL *)URL;

/**
 * Opens the given URL in the web view.
 */
- (void)openURL:(NSURL*)URL;

/**
 * Load the given request using UIWebView's loadRequest:.
 *
 *      @param request  A URL request identifying the location of the content to load.
 */
- (void)openRequest:(NSURLRequest*)request;


@end
