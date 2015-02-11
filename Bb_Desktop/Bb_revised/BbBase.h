//
//  BbBase.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbUI.h"
#import "BbConstants.h"

@class BbPort;

@protocol BbEntityParent <NSObject>
@optional

- (NSArray *)allowedTypesForPort:(BbPort *)port;
- (NSUInteger)indexForPort:(BbPort *)port;
- (NSUInteger)indexInParent:(BbEntity *)child;
- (BbEntity *)rootEntity;

@end

@interface BbEntity : NSObject <BbEntityParent>

@property (nonatomic,readonly)  NSUInteger          objectId;
@property (nonatomic,strong)    NSString            *name;
@property (nonatomic,strong)    NSMutableArray      *observers;
@property (nonatomic,strong)    NSMutableArray      *observed;
@property (nonatomic,weak)      id<BbEntityParent>  parent;
@property (nonatomic,strong)    id<BbEntityView>    view;

- (void)tearDown;
- (BbEntity *)rootEntity;

@end

@interface BbBang : BbEntity

+ (BbBang *)bang;

@property (nonatomic,strong)NSDate *timeStamp;

@end


