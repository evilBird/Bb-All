//
//  BbObject+Decoder.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@class BbObjectDescription;
@interface BbObject (Decoder)

+ (instancetype)newObjectClassName:(NSString *)className arguments:(id)arguments;
+ (BbObject *)objectWithDescription:(BbObjectDescription *)description;
+ (BbObject *)objectFromText:(NSString *)text;

@end
