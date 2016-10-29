//
//  ViewController.m
//  ghinhap
//
//  Created by quangpx on 7/10/15.
//  Copyright (c) 2015 fsoft. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "UIBarButtonItem+Badge.h"
#import "SWRevealViewController.h"
#import "SidebarViewController.h"
#import "Reachability.h"
#import "WTGlyphFontSet.h"
#import "NewsDetailViewController.h"

@interface ViewController(){
    WKWebView *_wkWebView;
    UIBarButtonItem *menuButton;
    UITextField *addressBar;
    UIView *loadingView;
}

- (void)loadWebView;

@end

@implementation ViewController
@synthesize selectedIndex;
@synthesize currentAddress;

#pragma mark - ViewController delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init custom layout
    [self initSidebar];
    [self initNotificationBadge];
    [self initAddressBar];
    [self initRefreshButton];
    [self initWKWebView];
    [self initLoadingIndicator];
    // Avoid status bar and navigation bar overlap
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Common function
    [self loadWebView];
    
    // Post notification
    NSDictionary* userInfo = @{@"index": @(selectedIndex)};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SetMainViewAddressBar" object:self userInfo:userInfo];
    if (selectedIndex == -2) {
        SidebarViewController *sideBar = (SidebarViewController *)self.revealViewController.rearViewController;
        sideBar.nhapIndexOnMainView = -2;
    }
    
    // Add observer notification
    [addressBar addTarget:self action:@selector(addressBarActive) forControlEvents:UIControlEventEditingDidBegin];
    [addressBar addTarget:self action:@selector(addressBarEndActive) forControlEvents:UIControlEventEditingDidEnd];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleView:) name:@"ToggleTheMenuView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayNewsNoti:) name:@"DisplayNewsNoti" object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect screenBound = self.view.bounds;
    _wkWebView.frame = CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height);
}

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect screenBound = self.view.bounds;
    _wkWebView.frame = CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height);
}

#pragma mark - WKWebView delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [loadingView setHidden:YES];
}

#pragma mark - Custom layout
- (void)initSidebar
{
    menuButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"bell.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIColor *tintColor = [UIColor colorWithRed:0.11 green:0.525 blue:0.976 alpha:1];
    [menuButton setTintColor:tintColor];
    //Add sidebar effect
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [menuButton setTarget: self.revealViewController];
        [menuButton setAction: @selector( revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)initNotificationBadge
{
    /* Badge for notification */
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    menuButton.badgeValue = [NSString stringWithFormat:@"%d", 3];
    menuButton.badgeBGColor = [UIColor orangeColor];
    menuButton.badgeOriginX = 33.5;
    [UIView commitAnimations];
}

- (void)initAddressBar
{
    CGRect screenBound = self.view.bounds;
    CGFloat widthForTextField = screenBound.size.width * 0.5;
    CGFloat heightForTextField;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        heightForTextField = screenBound.size.height * 0.03;
    } else {
        heightForTextField = screenBound.size.height * 0.05;
    }
    addressBar = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, widthForTextField, heightForTextField)];
    addressBar.font = [UIFont systemFontOfSize:heightForTextField / 2.3];
    addressBar.autocorrectionType = UITextAutocorrectionTypeNo;
    addressBar.keyboardType = UIKeyboardTypeDefault;
    addressBar.returnKeyType = UIReturnKeyDone;
    addressBar.clearButtonMode = UITextFieldViewModeWhileEditing;
    addressBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [addressBar setTextAlignment:NSTextAlignmentCenter];
    addressBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    addressBar.borderStyle = UITextBorderStyleRoundedRect;
    
    if (currentAddress != nil) {
        [addressBar setText:currentAddress];
    } else {
        [addressBar setText:@"http://hmtmoda.com/"];
    }
    [addressBar setTag:0];
    addressBar.delegate = self;
    
    [self.navigationItem.titleView setNeedsLayout];
    [self.navigationItem.titleView setNeedsDisplay];
    [self.navigationItem.titleView setNeedsUpdateConstraints];
    self.navigationItem.titleView = addressBar;
}

- (void)initWKWebView
{
    CGRect screenBound = self.view.bounds;
    _wkWebView = [[WKWebView alloc] init];
    _wkWebView.frame = CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height);
    _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _wkWebView.navigationDelegate = self;
    [_wkWebView setUserInteractionEnabled: YES];
    [self.view addSubview:_wkWebView];
}

- (void)initRefreshButton
{
    addressBar.rightView = nil;
    CGFloat widthForButton = addressBar.frame.size.width * 0.15;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        widthForButton = addressBar.frame.size.width * 0.1;
    }
    CGRect frame = CGRectMake(0,0,widthForButton,addressBar.frame.size.height);
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [refreshButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.frame = frame;
    refreshButton.font = [UIFont systemFontOfSize:18];
    [refreshButton setGlyphNamed:@"fontawesome##refresh"];
    [refreshButton setNeedsDisplay];
    addressBar.tintColor = [UIColor darkGrayColor];
    addressBar.rightView = refreshButton;
    addressBar.rightView.clipsToBounds = YES;
    addressBar.rightViewMode = UITextFieldViewModeUnlessEditing;
}

- (void)initLoadingIndicator
{
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(100, 400, 80, 80)];
    loadingView.center = _wkWebView.center;
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, 35);
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView addSubview:activityView];
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = @"Loading...";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [loadingView addSubview:lblLoading];
    
    [self.view addSubview:loadingView];
}

#pragma mark - Custom layout action
- (void)refreshAction:(UIButton *)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_wkWebView reload];
    });
}

- (BOOL)addressBarActive{
    [addressBar setTextAlignment:NSTextAlignmentLeft];
    return YES;
}

- (void)cancelAction{
    [addressBar resignFirstResponder];
}

- (BOOL)addressBarEndActive{
    [addressBar setTextAlignment:NSTextAlignmentCenter];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Common function
- (void)loadWebView
{
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:addressBar.text]];
    
    [_wkWebView loadRequest:requestObj];
    [loadingView setHidden:NO];
}

#pragma mark - Notification observation
- (void)toggleView:(NSNotification *)notification
{
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController revealToggle:self];
    
    NSString *link = notification.object;
    if (link != nil) {
        [addressBar setText:link];
        [self loadWebView];
    }
}

- (void)displayNewsNoti:(NSNotification *)notification
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NewsDetailViewController *newsDetailViewController = (NewsDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"newsDetailController"];
    NSDictionary *notiDict = (NSDictionary *)notification.object;
    Notification *notiObj = [notiDict objectForKey:@"notiDict"];
    newsDetailViewController.noti = notiObj;
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:newsDetailViewController];
    [self presentViewController:navBar animated:YES completion:nil];
}

@end

