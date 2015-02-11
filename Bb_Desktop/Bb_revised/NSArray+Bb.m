//
//  NSArray+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSArray+Bb.h"
#import <objc/runtime.h>

@implementation NSArray (Bb)

+ (NSArray *)typeArrayWithObjects:(NSArray *)objects
{
    if (!objects) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    for (id obj in objects) {
        NSString *className = NSStringFromClass(object_getClass(obj));
        if (className!=nil) {
            [result addObject:className];
        }
    }
    
    return result;
}

@end
