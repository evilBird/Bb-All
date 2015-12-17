//
//  NSDictionary+Bb.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BbBang;
@interface NSDictionary (Bb)

- (NSArray *)toArray;
- (NSString *)toString;
- (BbBang *)toBang;
- (NSDictionary *)toDictionary;

- (NSSet *)supportedConversions;

@end
