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

+ (Notification *)notiFromData:(NSData *)data error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    Notification *notification = [[Notification alloc] init];
    for (NSString *key in parsedObject) {
        if ([notification respondsToSelector:NSSelectorFromString(key)]) {
            [notification setValue:[parsedObject valueForKey:key] forKey:key];
        }
    }
    return notification;
}

+ (NSString *)generateDateStringWithEpoch:(NSString *)epoch
{
    NSTimeInterval seconds = [epoch doubleValue];
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSCalendar* calender = [NSCalendar currentCalendar];
    NSDateComponents* today = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents* currentDate = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:epochNSDate];
    NSString *dayPrefix = @"";
    if([today year] == [currentDate year] && [today month] == [currentDate month]){
        NSInteger diff = ([today day] - [currentDate day]);
        if(diff < 1){
            [dateFormat setDateFormat:@"hh:mm a"];
            dayPrefix = @"Today ";
        } else if(diff >= 1 || diff < 2){
            [dateFormat setDateFormat:@"hh:mm a"];
            dayPrefix = @"Yesterday ";
        } else {
            [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm a"];
        }
    } else {
        [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm a"];
    }
    return [dayPrefix stringByAppendingString:[dateFormat stringFromDate:epochNSDate]];
}

@end
