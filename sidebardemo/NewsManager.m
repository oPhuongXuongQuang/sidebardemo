//
//  NewsManager.m
//  sidebar-demo
//
//  Created by Quang Phuong on 10/26/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import "NewsManager.h"

@implementation NewsManager
@synthesize notificationManager;

- (void)fetchNewsByDeviceId:(int)device_id deviceName: (NSString *)device_name page:(int) page
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://hmtmoda.hifiveplus.vn/api/HMTModa?device_id=%d&device_name=%@&page=%d", device_id, device_name, page];
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

@end
