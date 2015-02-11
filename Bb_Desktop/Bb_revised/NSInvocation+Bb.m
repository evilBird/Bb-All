//
//  NSInvocation+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSInvocation+Bb.h"
#import "NSString+Bb.h"
#import "NSObject+Bb.h"
#import "BbUI.h"

#if TARGET_OS_IPHONE
// iOS code
#import <UIKit/UIKit.h>
#import <UIKit/UIKitDefines.h>

#else
// OSX code
#import <Cocoa/Cocoa.h>
#endif

@implementation NSInvocation (Bb)

- (void)setArgumentWithObject:(id)object atIndex:(NSUInteger)index
{
    NSInteger argIdx = 2+index;
    NSString *type = [NSString stringWithUTF8String:[self.methodSignature getArgumentTypeAtIndex:argIdx]];
    id arg = object;
    if ([type isEqualToString:[NSString encodeType:@encode(id)]]){
        id myArg = arg;
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(CGRect)]]){
        CGRect myArg = [arg CGRectValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(CGSize)]]){
        //CGSize myArg = [arg CGSizeValue];
        //[self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(CGPoint)]]){
        CGPoint myArg = [arg CGPointValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(CGAffineTransform)]]){
        CGAffineTransform myArg = [arg CGAffineTransformValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(NSInteger)]]){
        NSInteger myArg = [arg integerValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(NSUInteger)]]){
        NSUInteger myArg = [arg unsignedIntegerValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(long)]]){
        long myArg = [arg longValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(unsigned)]]){
        unsigned myArg = [arg unsignedIntValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(long long)]]){
        long long myArg = [arg longLongValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(int)]]){
        int myArg = [arg intValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(CGFloat)]]){
        CGFloat myArg = [arg doubleValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(float)]]){
        float myArg = [arg floatValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(double)]]){
        double myArg = [arg doubleValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSString encodeType:@encode(BOOL)]]){
        BOOL myArg = [arg boolValue];
        [self setArgument:&myArg atIndex:argIdx];
    }

}

@end
