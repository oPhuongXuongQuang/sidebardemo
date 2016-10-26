//
//  Notification.m
//  sidebar-demo
//
//  Created by Quang Phuong on 10/26/16.
//  Copyright © 2016 fsoft. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (id) initWithId:(NSString *)aId content:(NSString *)aContent link:(NSString *)aLink image:(NSString*) img time:(NSString *) aTime
{
    if(self = [super init]){
        _noti_id = aId;
        _noti_content = aContent;
        _noti_link = aLink;
        _noti_img = img;
        _noti_time = aTime;
    }
    return self;
}

+ (NSArray *)notiFromJSON:(NSData *)data error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *notis = [[NSMutableArray alloc] init];
    NSArray *notifications = [parsedObject valueForKey:@"notifications"];
    
    for (NSDictionary *notiDic in notifications) {
        Notification *notification = [[Notification alloc] init];
        
        for (NSString *key in notiDic) {
            if ([notification respondsToSelector:NSSelectorFromString(key)]) {
                [notification setValue:[notiDic valueForKey:key] forKey:key];
            }
        }
        
        [notis addObject:notification];
    }
    return notis;
}

@end
