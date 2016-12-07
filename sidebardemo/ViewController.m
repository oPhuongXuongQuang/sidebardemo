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
#import "NewsManager.h"

#define kDeviceId 11111
#define kDeviceName @"IOS"
#define kPage 0

@interface ViewController(){
    WKWebView *_wkWebView;
    UIBarButtonItem *menuButton;
//    UIButton *addressBar;
    UIBarButtonItem *addressBar;
    UIView *loadingView;
    NewsManager *_newsManager;
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
    [self initNavigationBar];
    [self initSidebar];
    [self initNotificationBadge];
    [self initAddressBar];
//    [self initRefreshButton];
    
    [self initWKWebView];
    [self initLoadingIndicator];
    // Avoid status bar and navigation bar overlap
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Common function
//    [self loadWebView];
    [self goToHome];
    
    // Post notification
    NSDictionary* userInfo = @{@"index": @(selectedIndex)};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SetMainViewAddressBar" object:self userInfo:userInfo];
    if (selectedIndex == -2) {
        SidebarViewController *sideBar = (SidebarViewController *)self.revealViewController.rearViewController;
        sideBar.nhapIndexOnMainView = -2;
    }
    
    // Add observer notification
//    [addressBar addTarget:self action:@selector(addressBarActive) forControlEvents:UIControlEventEditingDidBegin];
//    [addressBar addTarget:self action:@selector(addressBarEndActive) forControlEvents:UIControlEventEditingDidEnd];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleView:) name:@"ToggleTheMenuView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayNewsNoti:) name:@"DisplayNewsNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge:) name:@"UpdateBadge" object:nil];
    
    _newsManager = [[NewsManager alloc] init];
    
//    [self performSelectorInBackground:@selector(fetch) withObject:nil];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *isInit = @"true";
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchNewsNotification" object:isInit];
        [_newsManager fetchNewsByDeviceId:kDeviceId deviceName:kDeviceName page:kPage];
    });
}

//- (void)fetch
//{
//    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchNewsNotification" object:nil];
//    [_newsManager fetchNewsByDeviceId:kDeviceId deviceName:kDeviceName page:kPage];
//}

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
- (void)initNavigationBar
{
    NSString *logoName;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        logoName = @"topbar_ipad.png";
    } else {
        logoName = @"topbar.png";
    }
    UIImage *logo = [[UIImage imageNamed:logoName]
            
            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:logo forBarMetrics:UIBarMetricsDefault];
    
    NSLog(@"Nav Size: height %f - width %f",self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width);
    
    
}

- (void)initSidebar
{
    menuButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
////    menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next.png"] style:UIBarButtonItemStylePlain target:self action:nil];
////    menuButton.barTin
//    
//    [menuButton setTintColor:[UIColor clearColor]];
//    UIImage *bell = [[UIImage imageNamed:@"bell.png"]
//                     
//                     resizableImageWithCapInsets:UIEdgeInsetsMake(-20, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
//    [menuButton setBackgroundImage:bell forState:UIControlStateNormal barMetrics:0];
    

    //Add sidebar effect
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [menuButton setTarget: self.revealViewController];
        [menuButton setAction: @selector( rightRevealToggle:)];
        self.revealViewController.rightViewRevealOverdraw = 0.0;
    }
    self.navigationItem.rightBarButtonItem = menuButton;
    SidebarViewController *replacement = [[SidebarViewController alloc] init];
    [self.revealViewController setRightViewController:replacement animated:YES];
}

- (void)initNotificationBadge
{
    /* Badge for notification */
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    menuButton.badgeValue = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
    menuButton.badgeBGColor = [UIColor orangeColor];
    menuButton.badgeOriginX = 10.0;
    menuButton.badgeOriginY = -40;
    [UIView commitAnimations];
}

- (void)initAddressBar
{
    CGFloat widthForButton;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        widthForButton = 100;
    } else {
        widthForButton = 50;
    }
    
    UIButton *tmp = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, widthForButton, 100)];
    
    UIButton *button =
    [[UIButton alloc] initWithFrame:CGRectMake(0, 0, widthForButton *2.3, 100)];
    [button addTarget:self action:@selector(goToHome) forControlEvents:UIControlEventTouchUpInside];
    
    addressBar = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *tmpItem = [[UIBarButtonItem alloc] initWithCustomView:tmp];
    
//    [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(goToHome)];
    
    
//    [self.navigationItem.titleView setNeedsLayout];
//    [self.navigationItem.titleView setNeedsDisplay];
//    [self.navigationItem.titleView setNeedsUpdateConstraints];
//    self.navigationItem.titleView = addressBar;
    self.navigationItem.leftBarButtonItems = @[tmpItem, addressBar];
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

//- (void)initRefreshButton
//{
//    addressBar.rightView = nil;
//    CGFloat widthForButton = addressBar.frame.size.width * 0.15;
//    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
//        widthForButton = addressBar.frame.size.width * 0.1;
//    }
//    CGRect frame = CGRectMake(0,0,widthForButton,addressBar.frame.size.height);
//    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [refreshButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
//    refreshButton.frame = frame;
//    refreshButton.font = [UIFont systemFontOfSize:18];
//    [refreshButton setGlyphNamed:@"fontawesome##refresh"];
//    [refreshButton setNeedsDisplay];
//    addressBar.tintColor = [UIColor darkGrayColor];
//    addressBar.rightView = refreshButton;
//    addressBar.rightView.clipsToBounds = YES;
//    addressBar.rightViewMode = UITextFieldViewModeUnlessEditing;
//}

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
- (void)goToHome {
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hmtmoda.com/"]];
    
    [_wkWebView loadRequest:requestObj];
    [loadingView setHidden:NO];
}

- (void)gotToLink:(NSString *)link
{
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    
    [_wkWebView loadRequest:requestObj];
    [loadingView setHidden:NO];
}

- (void)refreshAction:(UIButton *)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_wkWebView reload];
    });
}

//- (BOOL)addressBarActive{
//    [addressBar setTextAlignment:NSTextAlignmentLeft];
//    return YES;
//}

//- (void)cancelAction{
//    [addressBar resignFirstResponder];
//}
//
//- (BOOL)addressBarEndActive{
//    [addressBar setTextAlignment:NSTextAlignmentCenter];
//    return YES;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Common function
//- (void)loadWebView
//{
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:addressBar.text]];
//    
//    [_wkWebView loadRequest:requestObj];
//    [loadingView setHidden:NO];
//}

- (void)toggleNotiBar
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.revealViewController rightRevealToggleAnimated:YES];
    });
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double x = (image.size.width - size.width) / 2.0;
    double y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

#pragma mark - Notification observation
- (void)toggleView:(NSNotification *)notification
{
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController rightRevealToggle:self];
    
    NSString *link = notification.object;
    if (link != nil) {
//        [addressBar setText:link];
        [self gotToLink:link];
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

- (void)updateBadge:(NSNotification *)notification
{
    NSLog(@"Update ne ahyhy");
    menuButton.badgeValue = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
}

@end

