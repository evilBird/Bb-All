//
//  NSString+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSString+Bb.h"
#import <objc/runtime.h>

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

+ (NSString*)encodeType:(char *)encodedType
{
    return [NSString stringWithUTF8String:encodedType];
}

+ (NSString *)stringWithFormat:(NSString *)formatString args:(NSArray *)args
{
    return nil;
}

@end
