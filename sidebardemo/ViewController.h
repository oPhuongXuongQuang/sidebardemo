//
//  ViewController.h
//  ghinhap
//
//  Created by quangpx on 7/10/15.
//  Copyright (c) 2015 fsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NhapItem.h"

@interface ViewController : UIViewController<UITextFieldDelegate,UIWebViewDelegate,UIScrollViewDelegate>{
    NSString *userName;
}

@property (nonatomic, strong) NSString *currentAddress;
@property NSInteger selectedIndex;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (void)shareAction;

@end
 
