//
//  NSString+Bb.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Bb)

+ (NSString *)encodeType:(char *)encodedType;
+ (NSString *)stringWithFormat:(NSString *)formatString args:(NSArray *)args;

@end
