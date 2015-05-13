//
//  NSObject+TypeConversion.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/13/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "NSObject+TypeConversion.h"
#import "NSValue+BSD.h"
static NSString *kTypeEncodingCGRect = @"{CGRect={CGPoint=dd}{CGSize=dd}}";

@implementation NSObject (TypeConversion)

+ (BOOL)methodSignature:(NSMethodSignature *)methodSignature argumentAtIndexReturnsRect:(NSUInteger)index
{
    NSString *argType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:index]];
    return [argType isEqualToString:kTypeEncodingCGRect];
}

+ (CGRect)rectFromObjectArg:(id)objectArg
{
    CGRect result = CGRectZero;
    
    if (![objectArg isKindOfClass:[NSValue class]]) {
        return result;
    }
    NSString *typeEncoding = [NSObject typeEncodingForValue:objectArg];
    if (![typeEncoding isEqualToString:kTypeEncodingCGRect]) {
        return result;
    }
    
    return [objectArg CGRectValue];
}

+ (NSString *)typeEncodingForValue:(NSValue *)value
{
    return [NSString stringWithUTF8String:[value objCType]];
}

@end
