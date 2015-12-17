//
//  NSString+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSString+Bb.h"
#import <objc/runtime.h>
#import "BbBase.h"

void printInts_v(int n, va_list ap)
{
    unsigned int i=0;
    for(i=0; i<n; i++)
    {
        int arg=va_arg(ap, int);
        printf("%d", arg);
    }
}

void printInts(int n,...)
{
    va_list ap;
    va_start(ap, n);
    printInts_v(n, ap);
    va_end(ap);
}

@implementation NSString (Bb)

#pragma mark - conversions

- (NSSet *)supportedConversions
{
    NSArray *conversions = @[@(BbValueType_Array),@(BbValueType_Number),@(BbValueType_Bang)];
    return [NSSet setWithArray:conversions];
}

- (NSString *)toString
{
    return self;
}

- (NSNumber *)toNumber
{
    return @([self floatValue]);
}

- (NSArray *)toArray
{
    return @[self];
}

- (NSArray *)delimitedArray:(NSString *)delimiter
{
    NSArray *components = nil;
    if (!delimiter) {
        components = [self componentsSeparatedByString:@" "];
    }else{
        components = [self componentsSeparatedByString:delimiter];
    }
    
    return components.mutableCopy;
}

- (BbBang *)toBang
{
    return [BbBang bang];
}

#pragma mark - class methods

+ (NSString*)encodeType:(char *)encodedType
{
    return [NSString stringWithUTF8String:encodedType];
}

+ (NSString *)stringWithFormat:(NSString *)formatString args:(NSArray *)args
{
    return nil;
}

+ (NSString *)displayTextName:(NSString *)name args:(id)args
{
    if (!name) {
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc]init];
    [result appendString:name];
    if (!args) {
        return result;
    }
    [result appendString:@" "];
    [result appendString:[NSString stringWithArgs:args]];
    return result;
}

+ (NSString *)stringWithArgs:(id)args
{
    if ([args isKindOfClass:[NSArray class]]) {
        return [NSString stringWithArray:args];
    }else{
        return [NSString stringWithFormat:@"%@",args];
    }
}

+ (NSString *)stringWithArray:(NSArray *)array
{
    if (!array) {
        return @"";
    }
    
    NSMutableString *result = [[NSMutableString alloc]init];
    NSUInteger index = 0;
    for (id arg in array) {
        if (index > 0) {
            [result appendString:@" "];
        }
        
        [result appendFormat:@"%@",arg];
        
        index ++;
    }
    
    return result;
}

@end
