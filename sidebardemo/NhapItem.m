//
//  NhapItem.m
//  ghinhap
//
//  Created by Quang Phuong on 7/20/15.
//  Copyright © 2015 fsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NhapItem.h"


@implementation NhapItem

- (id)initWithName:(NSString *)aName createDate:(NSDate *)aCreateDate isLocal:(NSNumber *)aIsLocal owner:(NSString *)aOwner{
    if(self = [super init]){
        _name = aName;
        _createDate = aCreateDate;
        _isLocal = aIsLocal;
        _owner = aOwner;
        _data = @"";
    }
    return self;
}

- (id)initWithName:(NSString *)aName isLocal:(NSNumber *)aIsLocal
{
    if(self = [super init]){
        _name = aName;
        _isLocal = aIsLocal;
    }
    return self;
}

@end

