//
//  BbBase.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBase.h"

#pragma mark - BbEntity Implementation

@implementation BbEntity

- (NSUInteger)objectId
{
    return [self hash];
}

- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%p",self]hash];
}

- (BOOL)isEqual:(id)object
{
    return (self.objectId == [object hash]);
}

- (NSUInteger)countAncestors
{
    if (self.parent != nil) {
        return ([self.parent countAncestors]+1);
    }else{
        return 0;
    }
}

- (void)tearDown{
    
    self.name = nil;
}

- (void)dealloc
{
    [self tearDown];
}

#pragma mark - BbEntityParent 

- (BbEntity *)rootEntity
{
    if (!self.parent) {
        return self;
    }
    
    return [self.parent rootEntity];
}

@end

#pragma mark - BbBang Implementation

@implementation BbBang

+ (BbBang *)bang
{
    return [[BbBang alloc]init];
}

- (BbBang *)copyWithZone:(NSZone *)zone
{
    return [BbBang bang];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeStamp = [NSDate date];
        self.name = @"BANG";
    }
    
    return self;
}

- (void)tearDown
{
    [super tearDown];
    self.timeStamp = nil;
}

@end
