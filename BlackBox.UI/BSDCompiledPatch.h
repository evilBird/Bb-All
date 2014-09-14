//
//  BSDCompiledPatch.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDObjectDescription.h"
#import "BSDPortConnectionDescription.h"

@class BSDCanvas;
@interface BSDCompiledPatch : BSDObject

- (instancetype)initWithCanvas:(BSDCanvas *)canvas;
- (void)addObjectWithDescription:(BSDObjectDescription *)description;
- (void)addConnectionWithDescription:(BSDPortConnectionDescription *)description;

@end
