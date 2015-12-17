//
//  NSNumber+Bb.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSNumber+Bb.h"
#import "BbBase.h"
@implementation NSNumber (Bb)

- (NSSet *)supportedConversions
{
    NSArray *conversions = @[@(BbValueType_String),@(BbValueType_Array),@(BbValueType_Bang)];
    return [NSSet setWithArray:conversions];
}

- (NSString *)toString
{
    return [self stringValue];
}

- (NSArray *)toArray
{
    return @[self];
}

- (BbBang *)toBang
{
    return [BbBang bang];
}

@end
