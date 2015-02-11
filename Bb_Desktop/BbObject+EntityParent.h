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

- (NSArray *)allowedTypesForPort:(BbPort *)port;
- (NSInteger)indexForPort:(BbPort *)port;

@end
