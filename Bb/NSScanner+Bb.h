//
//  NSScanner+Bb.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSScanner (Bb)

+ (NSUInteger)scanStackIndex:(NSScanner **)scanner;
+ (NSString *)scanStackInstruction:(NSScanner **)scanner;
+ (NSString *)scanUIType:(NSScanner **)scanner;
+ (NSValue *)scanUICenter:(NSScanner **)scanner;
+ (NSArray *)scanUIPosition:(NSScanner **)scanner;
+ (NSValue *)scanUISize:(NSScanner **)scanner;
+ (NSString *)scanObjectType:(NSScanner **)scanner;
+ (NSArray *)scanObjectArgs:(NSScanner **)scanner;
+ (NSArray *)scanConnectionArgs:(NSScanner **)scanner;

+ (NSCharacterSet *)validArgCharacterSet;

@end
