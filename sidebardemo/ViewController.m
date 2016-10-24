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

@interface ViewController(){
    UIWebView* _webView;
    NSMutableArray *barItems;
    UIColor *tintColor;
    UIBarButtonItem *menuButton;
    UITextField *addressBar;
}

- (void)loadWebOnline;

@property BOOL isKeyboardShowing;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation ViewController

@synthesize toolBar;
@synthesize selectedIndex;
@synthesize currentAddress;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"bell.png"] style:UIBarButtonItemStylePlain target:nil action:nil];

    self.navigationItem.leftBarButtonItem = menuButton;
    
    [self createBadge];
    
    tintColor = [UIColor colorWithRed:0.11 green:0.525 blue:0.976 alpha:1];
    [menuButton setTintColor:tintColor];
    //Add sidebar effect
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [menuButton setTarget: self.revealViewController];
        [menuButton setAction: @selector( revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }    
    
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
        [addressBar setText:@"http://www.google.com"];
    }
    [addressBar setTag:0];
    addressBar.delegate = self;
    
    // Add refresh button
    [self addRefreshButton];
    
    _webView = [[UIWebView alloc] init];
    _webView.frame = CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height);
    _webView.delegate = self;
    [self loadWebOnline];
    
    [_webView setUserInteractionEnabled: YES];
    [self.view addSubview:_webView];
    
    
    [addressBar addTarget:self action:@selector(addressBarActive) forControlEvents:UIControlEventEditingDidBegin];
    [addressBar addTarget:self action:@selector(addressBarEndActive) forControlEvents:UIControlEventEditingDidEnd];
    [self.navigationItem.titleView setNeedsLayout];
    [self.navigationItem.titleView setNeedsDisplay];
    [self.navigationItem.titleView setNeedsUpdateConstraints];
    self.navigationItem.titleView = addressBar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleView:) name:@"ToggleTheMenuView" object:nil];
    
    NSDictionary* userInfo = @{@"index": @(selectedIndex)};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SetMainViewAddressBar" object:self userInfo:userInfo];
    if (selectedIndex == -2) {
        SidebarViewController *sideBar = (SidebarViewController *)self.revealViewController.rearViewController;
        sideBar.nhapIndexOnMainView = -2;
    }
    
    _webView.scrollView.delegate = self;
    
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)viewWillAppear:(BOOL)animated{
    [self addKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self removeKeyboardNotifications];
}

- (void)addRefreshButton
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

- (void)refreshAction:(UIButton *)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_webView reload];
    });
}

- (void)toggleView:(NSNotification *)notification
{
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController revealToggle:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect screenBound = self.view.bounds;
    _webView.frame = CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height);
}

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect screenBound = self.view.bounds;
    _webView.frame = CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)loadWebOnline
{
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:addressBar.text]];
    
    [_webView loadRequest:requestObj];
}

//call this from viewWillAppear
-(void)addKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
//call this from viewWillDisappear
- (void)removeKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

- (void)keyboardDidShow:(NSNotification*)aNotification{
    _isKeyboardShowing = YES;
}

- (void)keyboardDidHide:(NSNotification*)aNotification{
    _isKeyboardShowing = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)createBadge
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

@end

