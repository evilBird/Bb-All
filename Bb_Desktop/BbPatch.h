//
//  BbPatch.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+EntityParent.h"

@interface BbPatch : BbObject

- (void)addChildObject:(BbObject *)childObject;
- (void)removeChildObject:(BbObject *)childObject;
- (void)addChildObjectWithText:(NSString *)text;

@end
