//
//  NSArray+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSArray+Bb.h"
#import <objc/runtime.h>
#import "NSString+Bb.h"
#import "BbBase.h"
#import "NSObject+Bb.h"

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

- (NSSet *)supportedConversions
{
    NSArray *conversions = nil;
    switch (self.count) {
        case 0:
            conversions = @[@(BbValueType_String),@(BbValueType_Bang)];
            break;
            case 1:
            conversions = @[@(BbValueType_String),@(BbValueType_Number),@(BbValueType_Bang)];
            break;
        default:
            conversions =  @[@(BbValueType_String),@(BbValueType_Number),@(BbValueType_Bang),@(BbValueType_Array)];
            break;
    }
    
    return [NSSet setWithArray:conversions];
}

- (NSDictionary *)toDictionary
{
    if (self.count <= 1) {
        return nil;
    }
    
    NSMutableArray *selfCopy = self.mutableCopy;
    BOOL trimLastObject = (selfCopy.count%2 == 1);
    if (trimLastObject) {
        [selfCopy removeObjectAtIndex:(selfCopy.count - 1)];
    }
    
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    NSUInteger i = 0;
    id currentKey = nil;
    for (id object in selfCopy) {
        if (i%2 == 0) {
            currentKey = object;
        }else{
            id myKey = [currentKey copy];
            temp[myKey] = object;
            currentKey = nil;
        }
        i++;
    }
    
    return [NSDictionary dictionaryWithDictionary:temp];
}

- (NSNumber *)toNumber
{
    if (self.count != 1) {
        return nil;
    }
    
    if ([self.firstObject isKindOfClass:[NSNumber class]]) {
        return [self.firstObject copy];
    }else if ([self.firstObject isKindOfClass:[NSString class]]){
        return [(NSString *)self.firstObject toNumber];
    }
    
    return nil;
}

- (NSArray *)toArray
{
    return self;
}

- (NSString *)toString
{
    if (self.count == 0) {
        return @"";
    }
    
    if (self.count == 1 && [self.firstObject isKindOfClass:[NSString class]]) {
        return [self.firstObject copy];
    }
    
    NSString *arrayString = [NSString stringWithArray:self.mutableCopy];
    return arrayString;
}

- (BbBang *)toBang
{
    return [BbBang bang];
}

@end
