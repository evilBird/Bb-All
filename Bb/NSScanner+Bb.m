//
//  NSScanner+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSScanner+Bb.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#if TARGET_OS_IPHONE
// iOS code
#import <UIKit/UIKit.h>
#import <UIKit/UIKitDefines.h>

#else
// OSX code
#import <Cocoa/Cocoa.h>
#endif

@implementation NSScanner (Bb)

+ (NSUInteger)scanStackIndex:(NSScanner **)scanner
{
    NSScanner *indexScanner = *scanner;
    indexScanner.charactersToBeSkipped = nil;
    BOOL didScan = YES;
    NSUInteger result = -1;
    while (didScan) {
        result++;
        didScan = [indexScanner scanString:@"\t" intoString:NULL];
    }
    indexScanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];
    return result;
}

+ (NSString *)scanStackInstruction:(NSScanner **)scanner
{
    NSScanner *instructionScanner = *scanner;
    NSString *result = nil;
    BOOL didScan = YES;
    NSCharacterSet *instructionChars = [NSCharacterSet characterSetWithCharactersInString:@"#NXR"];
    while (didScan) {
        didScan = [instructionScanner scanCharactersFromSet:instructionChars intoString:&result];
    }
    
    return result;
}

+ (NSString *)scanUIType:(NSScanner **)scanner
{
    NSScanner *UITypeScanner = *scanner;
    NSString *result = nil;
    BOOL didScan = NO;
    NSArray *UITypes = @[@"canvas",@"obj",@"text",@"msg",@"inlet",@"outlet",@"connect",@"hsl",@"bang",@"restore"];
    for (NSString *UIType in UITypes) {
        didScan = [UITypeScanner scanString:UIType intoString:&result];
        if (didScan) {
            return result;
        }
    }
    
    return nil;
}

+ (NSValue *)scanUICenter:(NSScanner **)scanner
{
    NSScanner *centerScanner = *scanner;
    NSValue *result = nil;
    BOOL didScan = YES;
    double vals[2];
    NSUInteger count = 0;
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    while (didScan && count < 2) {
        NSString *numberString = nil;
        didScan = [centerScanner scanCharactersFromSet:numbers intoString:&numberString];
        if (didScan && numberString) {
            vals[count] = numberString.integerValue;
            count++;
        }
    }
    
    if (count == 2) {
        CGPoint center = CGPointMake(vals[0], vals[1]);
        result = [NSValue value:&center withObjCType:@encode(CGPoint)];
    }
    
    return result;
}

+ (NSArray *)scanUIPosition:(NSScanner **)scanner
{
    NSScanner *centerScanner = *scanner;
    NSArray *result = nil;
    BOOL didScan = YES;
    double vals[2];
    NSUInteger count = 0;
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    while (didScan && count < 2) {
        NSString *numberString = nil;
        didScan = [centerScanner scanCharactersFromSet:numbers intoString:&numberString];
        if (didScan && numberString) {
            vals[count] = numberString.integerValue;
            count++;
        }
    }
    
    if (count == 2) {
        result = @[@(vals[0]),@(vals[1])];
    }
    
    return result;
}


+ (NSValue *)scanUISize:(NSScanner **)scanner
{
    NSScanner *sizeScanner = *scanner;
    NSValue *result = nil;
    BOOL didScan = YES;
    double vals[2];
    NSUInteger count = 0;
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    while (didScan && count < 2) {
        NSString *numberString = nil;
        didScan = [sizeScanner scanCharactersFromSet:numbers intoString:&numberString];
        if (didScan && numberString) {
            vals[count] = numberString.integerValue;
            count++;
        }
    }
    
    if (count == 2) {
        CGSize center = CGSizeMake(vals[0], vals[1]);
        result = [NSValue value:&center withObjCType:@encode(CGSize)];
    }
    
    return result;
}

+ (NSString *)scanObjectType:(NSScanner **)scanner
{
    NSScanner *classScanner = *scanner;
    classScanner.charactersToBeSkipped = nil;
    NSString *result = nil;
    BOOL didScanChar = YES;
    BOOL didScanSpace = NO;
    NSCharacterSet *chars = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    BOOL done = NO;
    while (!done) {
        
        didScanChar = [classScanner scanCharactersFromSet:chars intoString:&result];
        didScanSpace = [classScanner scanCharactersFromSet:ws intoString:NULL];
        
        if (didScanSpace && result!=nil) {
            done = YES;
        }
    }
    
    classScanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return result;
}

+ (NSArray *)scanObjectArgs:(NSScanner **)scanner
{
    NSScanner *argsScanner = *scanner;
    argsScanner.charactersToBeSkipped = nil;
    NSArray *result = nil;
    BOOL didScanEndChar = NO;
    BOOL didScanWhiteSpace = NO;
    NSMutableArray *temp = [NSMutableArray array];
    NSCharacterSet *endChar = [NSCharacterSet characterSetWithCharactersInString:@";"];
    NSCharacterSet *argChars = [NSScanner validArgCharacterSet];
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
    NSString *arg = nil;
    BOOL done = NO;
    while (!done) {
        didScanEndChar = [argsScanner scanCharactersFromSet:endChar intoString:NULL];
        if (!didScanEndChar) {
            didScanWhiteSpace = [argsScanner scanCharactersFromSet:ws intoString:NULL];
            if (didScanWhiteSpace) {
                if (arg && ![temp containsObject:arg]) {
                    [temp addObject:[arg copy]];
                    arg = nil;
                }else{
                    didScanEndChar = [argsScanner scanCharactersFromSet:endChar intoString:NULL];
                    if (didScanEndChar) {
                        done = YES;
                    }
                }
            }else{
                [argsScanner scanCharactersFromSet:argChars intoString:&arg];
            }
        }else{
            if (arg) {
                [temp addObject:[arg copy]];
                arg = nil;
            }
            
            done = YES;
        }
        
        //done = argsScanner.isAtEnd;
        //NSUInteger loc = argsScanner.scanLocation;
        //NSUInteger len = argsScanner.string;
        
    }
    
    if (temp) {
        result = [NSArray arrayWithArray:temp];
    }
    argsScanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return result;
}

+ (NSArray *)scanConnectionArgs:(NSScanner *__autoreleasing *)scanner
{
    NSScanner *argsScanner = *scanner;
    NSArray *result = nil;
    BOOL didScanNumber = NO;
    BOOL done = NO;
    NSMutableArray *temp = [NSMutableArray array];
    NSCharacterSet *intChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    while (!done) {
        NSString *numString = nil;
        didScanNumber = [argsScanner scanCharactersFromSet:intChars intoString:&numString];
        if (didScanNumber && numString) {
            NSNumber *number = @(numString.integerValue);
            [temp addObject:number];
        }
        
        if (temp.count == 4 || argsScanner.isAtEnd) {
            done = YES;
        }
    }
    
    if (temp) {
        result = [NSArray arrayWithArray:temp];
    }
    
    return result;
}

+ (NSCharacterSet *)validArgCharacterSet
{
    return [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890./?><:!@#$%^&*()~`'<>-_=+"];
}

@end
