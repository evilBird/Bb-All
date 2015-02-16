//
//  BbObject+EntityParent.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@interface BbObject (EntityParent)

#pragma mark - BbEntityParent Methods

- (NSSet *)allowedTypesForPort:(BbPort *)port;
- (NSInteger)indexOfPort:(BbPort *)port;
- (NSUInteger)indexOfChild:(BbEntity *)child;
- (void)addChildObject:(BbObject *)childObject;
- (void)removeChildObject:(BbObject *)childObject;

@end
