//
//  NotificationManager.m
//  sidebar-demo
//
//  Created by Quang Phuong on 10/26/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import "NotificationManager.h"
#import "Notification.h"

@implementation NotificationManager

- (void)receivedNotificationJSON:(NSData *)data
{
    NSError *error = nil;
    NSArray *notis = [Notification notiFromJSON:data error: &error];
    if (error != nil) {
        NSLog(@"Error %@; %@", error, [error localizedDescription]);
    } else {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:notis forKey:@"notis"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveNewsNotification" object:dict];
        }];
    }
}

- (void)receivedError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}
@end
