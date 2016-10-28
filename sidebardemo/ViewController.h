//
//  ViewController.h
//  ghinhap
//
//  Created by quangpx on 7/10/15.
//  Copyright (c) 2015 fsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate,UIWebViewDelegate,UIScrollViewDelegate>{
    NSString *userName;
}

@property (nonatomic, strong) NSString *currentAddress;
@property NSInteger selectedIndex;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end
 
