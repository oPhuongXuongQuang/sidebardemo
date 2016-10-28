//
//  NewsDetailViewController.m
//  sidebar-demo
//
//  Created by Quang Phuong on 10/28/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "SWRevealViewController.h"

@interface NewsDetailViewController ()
@property (nonatomic) UITextView *newsContent;
@property (nonatomic) UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *link;

@end

@implementation NewsDetailViewController
@synthesize noti;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenBound = self.view.bounds;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _newsContent = [[UITextView alloc] initWithFrame:CGRectMake(0, 150, screenBound.size.width, screenBound.size.height)];
    self.link.frame = CGRectMake(self.link.frame.origin.x, self.link.frame.origin.y, screenBound.size.width * 0.8, 10);
    [self.newsContent setText:noti.noti_content];
    [self.link setText:noti.noti_link];
    
    [self.view addSubview:scrollView];
    [scrollView addSubview:self.newsContent];
    
    // Make textView dynamic height
    [self.newsContent sizeToFit];
    [self.newsContent layoutIfNeeded];
    [self.link sizeToFit];
    [self.link layoutIfNeeded];
    
    _newsImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(scrollView.bounds) - screenBound.size.width * 0.6 /2, _newsContent.frame.size.height + 160, screenBound.size.width * 0.6, screenBound.size.height * 0.3)];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:noti.noti_img]];
    self.newsImage.image = [UIImage imageWithData:data];
    
    
    [self.link setText:noti.noti_link];
    [self.date setText: [Notification generateDateStringWithEpoch: noti.noti_time]];
    
    
    _date.layoutMargins = UIEdgeInsetsMake(50, 0, 0, 0);
    _newsContent.layoutMargins = UIEdgeInsetsMake(150, 20, 0, 20);
    
    _newsImage.layoutMargins = UIEdgeInsetsMake(150, 10, 0, 10);
    
    [scrollView addSubview:self.newsImage];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelView)];
    
}

- (void) cancelView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    SWRevealViewController *revealController = [[SWRevealViewController alloc] init];
    [self presentViewController:revealController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
