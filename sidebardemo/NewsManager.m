//
//  NewsManager.m
//  sidebar-demo
//
//  Created by Quang Phuong on 10/26/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import "NewsManager.h"

#define kNotificationSideBarAPI @"http://hmtmoda.hifiveplus.vn/api/HMTModa?device_id=%d&device_name=%@&page=%d"
#define kPushNotificationAPI @"http://hmtmoda.hifiveplus.vn/api/HMTModa?gcm_id=%@&device_id=%@&device_name=%@"

@implementation NewsManager
@synthesize notificationManager;

- (void)fetchNewsByDeviceId:(int)device_id deviceName: (NSString *)device_name page:(int) page
{
    NSString *urlAsString = [NSString stringWithFormat:kNotificationSideBarAPI, device_id, device_name, page];
    NSURL *url = [NSURL URLWithString:urlAsString];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        notificationManager = [NotificationManager new];
        if (error) {
            [notificationManager receivedError:error];
        } else {
            [notificationManager receivedNotificationJSON:data];
        }
    }];
}

+ (void)registerOnServerWithToken:(NSString *)gcm_id deviceId:(NSString *)device_id deviceName:(NSString *)device_name
{
    NSString *urlAsString = [NSString stringWithFormat:kPushNotificationAPI, gcm_id, device_id, device_name];
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error %@; %@", error, [error localizedDescription]);
        } else {
            NSLog(@"Register token success!");
        }
    }];
}

@end
