//
//  NSString+Bb.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BbBang;
@interface NSString (Bb)

+ (NSString *)encodeType:(char *)encodedType;
+ (NSString *)stringWithFormat:(NSString *)formatString args:(NSArray *)args;
+ (NSString *)displayTextName:(NSString *)name args:(id)args;
+ (NSString *)stringWithArray:(NSArray *)array;

- (NSSet *)supportedConversions;
- (NSNumber *)toNumber;
- (NSArray *)toArray;
- (NSString *)toString;
- (NSArray *)delimitedArray:(NSString *)delimiter;
- (BbBang *)toBang;

@end
