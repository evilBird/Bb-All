//
//  NSObject+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSObject+Bb.h"
#import "NSString+Bb.h"

@implementation NSObject (Bb)

+ (NSUInteger)typeCode:(char *)type
{
    return [[NSString encodeType:type]hash];
}

@end
