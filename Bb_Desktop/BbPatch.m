//
//  BbPatch.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch.h"

@implementation BbPatch

#pragma child objects

- (void)addChildObjectWithText:(NSString *)text
{
    
}

- (void)addChildObject:(BbObject *)childObject
{
    if (!childObject || [self.childObjects_ containsObject:childObject]) {
        return;
    }
    
    if (!self.childObjects_) {
        self.childObjects_ = [NSMutableArray array];
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
        return [NSArray arrayWithArray:self.childObjects_];
    }
    
    return nil;
}

- (void)tearDown
{
    [super tearDown];
    
    for (BbObject *childObject in self.childObjects_) {
        [self removeChildObject:childObject];
        [childObject tearDown];
    }
    
    self.childObjects_ = nil;
    
}

@end
