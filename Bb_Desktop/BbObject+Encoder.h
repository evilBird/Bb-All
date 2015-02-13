//
//  BbObject+Encoder.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@class BbDescription,BbObjectDescription,BbPatchDescription,BbConnectionDescription;

@interface BbObject (Encoder)

- (BbDescription *)encodeDescription;
- (NSString *)UIType;

@end
