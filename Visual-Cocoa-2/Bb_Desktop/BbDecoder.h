//
//  BbObjectFactory.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbUI.h"
#import "BbObject.h"
#import "BbParsers.h"

@interface BbDecoder : NSObject

+ (BbObject *)objectWithText:(NSString *)text;
+ (BbObject *)objectWithDescription:(BbObjectDescription *)description;

@end
