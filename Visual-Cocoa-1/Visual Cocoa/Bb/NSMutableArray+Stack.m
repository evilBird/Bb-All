//
//  NSMutableArray+Stack.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

- (void)push:(id)toPush
{
    if (toPush != nil) {
        [self addObject:toPush];
    }
}

- (id)pop
{
    if (self.count == 0) {
        return nil;
    }else{
        id popped = self.lastObject;
        [self removeObjectIdenticalTo:popped];
        return popped;
    }
}

@end
