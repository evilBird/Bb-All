//
//  NSArray+Bb.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BbBang;
@interface NSArray (Bb)



+ (NSArray *)typeArrayWithObjects:(NSArray *)objects;
- (NSSet *)supportedConversions;
- (NSDictionary *)toDictionary;
- (NSNumber *)toNumber;
- (NSString *)toString;
- (BbBang *)toBang;
- (NSArray *)toArray;

@end
