//
//  ViewController.h
//  ghinhap
//
//  Created by quangpx on 7/10/15.
//  Copyright (c) 2015 fsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface ViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,WKNavigationDelegate>

@property (nonatomic, strong) NSString *currentAddress;
@property NSInteger selectedIndex;

@end
 
