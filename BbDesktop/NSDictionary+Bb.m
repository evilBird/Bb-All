//
//  NSDictionary+Bb.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSDictionary+Bb.h"
#import "BbBase.h"
#import "NSObject+Bb.h"
#import "NSArray+Bb.h"

@implementation NSDictionary (Bb)

- (NSArray *)toArray
{
    NSMutableArray *temp = [NSMutableArray array];
    for (id key in self.allKeys) {
        [temp addObject:key];
        id value = self[key];
        [temp addObject:value];
    }
    
    return [NSArray arrayWithArray:temp];
}

- (NSString *)toString
{
    NSArray *arr = [self toArray];
    return [arr toString];
}

- (BbBang *)toBang
{
    return [BbBang bang];
}

- (NSSet *)supportedConversions
{
    NSArray *conversions = @[@(BbValueType_Array),@(BbValueType_Bang),@(BbValueType_String)];
    return [NSSet setWithArray:conversions];
}


@end
