//
//  NhapItem.h
//  ghinhap
//
//  Created by Quang Phuong on 7/20/15.
//  Copyright © 2015 fsoft. All rights reserved.
//

#ifndef NhapItem_h
#define NhapItem_h


@interface NhapItem : NSObject

@property NSString *name;
@property NSDate *createDate;
@property NSNumber *isLocal;
@property NSString *owner;
@property NSString *data;

- (id)initWithName:(NSString *)aName createDate:(NSDate *)aCreateDate isLocal:(NSNumber *)aIsLocal owner:(NSString *)aOwner;

- (id)initWithName:(NSString *)aName isLocal:(NSNumber *)aIsLocal;

@end

#endif /* NhapItem_h */
