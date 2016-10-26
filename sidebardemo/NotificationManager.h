//
//  NotificationManager.h
//  sidebar-demo
//
//  Created by Quang Phuong on 10/26/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsManager.h"

@interface NotificationManager : NSObject 

- (void)receivedNotificationJSON:(NSData *)data;
- (void)receivedError:(NSError *)error;

@end
