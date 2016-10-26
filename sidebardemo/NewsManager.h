//
//  NewsManager.h
//  sidebar-demo
//
//  Created by Quang Phuong on 10/26/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationManager.h"

@class NotificationManager;
@interface NewsManager : NSObject

@property (strong) NotificationManager *notificationManager;
- (void)fetchNewsByDeviceId:(int)device_id deviceName: (NSString *)device_name page:(int) page;

@end
