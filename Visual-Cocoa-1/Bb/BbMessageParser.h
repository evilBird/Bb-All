//
//  BbMessageParser.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+MessageQueue.h"

@interface BbMessageParser : NSObject

+ (id)messageFromText:(NSString *)text;
+ (id)setTypeForString:(NSString *)string;

@end
