//
//  BbObject+EntityParent.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+EntityParent.h"
#import "BbObject.h"

@implementation BbObject (EntityParent)

#pragma mark - BbEntityParent Methods

- (NSArray *)allowedTypesForPort:(BbPort *)port
{
    return nil;
}

- (NSInteger)indexForPort:(BbPort *)port
{
    if ([port isKindOfClass:[BbInlet class]] && [self.inlets containsObject:port]) {
        return [self.inlets indexOfObject:port];
    }
    
    if ([port isKindOfClass:[BbOutlet class]] && [self.outlets containsObject:port]) {
        return [self.outlets indexOfObject:port];
    }
    
    return -1;
}

- (NSUInteger)indexForObject:(BbObject *)object
{
    if (!self.childObjects_ || ![self.childObjects_ containsObject:object]) {
        return -1;
    }
    
    return [self.childObjects_ indexOfObjectIdenticalTo:object];
}

- (NSUInteger)indexInParent:(BbEntity *)child
{
    if ([child isMemberOfClass:[BbPort class]]) {
        return [self indexForPort:(BbPort *)child];
    }
    
    if ([child isMemberOfClass:[BbObject class]]) {
        return [self indexForObject:(BbObject *)child];
    }
    
    return -1;
}

@end
