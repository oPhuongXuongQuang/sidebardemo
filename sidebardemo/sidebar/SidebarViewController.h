//
//  SidebarViewController.h
//  ghinhap
//
//  Created by Quang Phuong on 7/19/15.
//  Copyright © 2015 fsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsManager.h"

@interface SidebarViewController : UITableViewController

@property NSArray *notiList;
@property (nonatomic) NSInteger nhapIndexOnMainView;
@property (nonatomic) NewsManager *newsManager;

@end
