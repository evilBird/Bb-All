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

- (NSSet *)allowedTypesForPort:(BbPort *)port
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
    if (!object || !self.childObjects_ || ![self.childObjects_ containsObject:object]) {
        return -1;
    }
    
    return [self.childObjects_ indexOfObject:object];
}

- (NSUInteger)indexInParent:(BbEntity *)child
{
    if ([child isKindOfClass:[BbPort class]]) {
        return [self indexForPort:(BbPort *)child];
    }
    
    if ([child isKindOfClass:[BbObject class]]) {
        return [self indexForObject:(BbObject *)child];
    }
    
    return -1;
}

- (void)addChildObject:(BbObject *)childObject
{
    if (!childObject || [self.childObjects_ containsObject:childObject]) {
        return;
    }
    
    if (!self.childObjects_) {
        self.childObjects_ = [[NSMutableOrderedSet alloc]init];
    }
    
    childObject.parent = self;
    [self.childObjects_ addObject:childObject];
    
    if (self.view) {
        [self.view addSubview:childObject.view];
    }
}

- (void)removeChildObject:(BbObject *)childObject
{
    if (!childObject || !self.childObjects_ || ![self.childObjects_ containsObject:childObject]) {
        return;
    }
    
    childObject.parent = nil;
    [self.childObjects_ removeObject:childObject];
    
    if (self.childObjects_.count < 1) {
        self.childObjects_ = nil;
    }
    
    if (childObject.view) {
        [childObject.view removeFromSuperview];
    }
    
    [childObject tearDown];
}

- (NSArray *)childObjects
{
    if (self.childObjects_ && self.childObjects_.count > 0) {
        return self.childObjects_.array.mutableCopy;
    }
    
    return nil;
}

@end
