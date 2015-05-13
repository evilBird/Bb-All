//
//  NSString+BSD.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/13/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "NSString+BSD.h"

@implementation NSString (BSD)

- (BOOL)isStringLiteral
{
    if (self.length <= 2) {
        return NO;
    }
    
    NSRange range;
    range.location = 0;
    range.length = 1;
    NSString *firstChar = [self substringWithRange:range];
    range.location = self.length - 1;
    NSString *lastChar = [self substringWithRange:range];
    if ([firstChar isEqualToString:@"\""]&&[lastChar isEqualToString:@"\""]){
        return YES;
    }
    
    return NO;
}

- (NSString *)stringFromLiteral
{
    if (![self isStringLiteral]) {
        return nil;
    }
    
    return [self stringByReplacingOccurrencesOfString:@"\"" withString:@""];
}
        
        

@end
