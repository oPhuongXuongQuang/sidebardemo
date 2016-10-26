//
//  Notification.h
//  sidebar-demo
//
//  Created by Quang Phuong on 10/26/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property NSString *noti_id;
@property NSString *noti_content;
@property NSString *noti_link;
@property NSString *noti_img;
@property NSString *noti_time;

- (id) initWithId:(NSString *)aId content:(NSString *)aContent link:(NSString *)aLink image:(NSString*) img time:(NSString *) aTime;

+ (NSArray *)notiFromJSON:(NSData *)data error:(NSError **)error;

@end
