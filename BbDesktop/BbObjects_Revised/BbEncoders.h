//
//  BbEncoders.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbParsers.h"

@interface BbObject (Encode)

- (BbDescription *)description;
- (BbObjectDescription *)objectDescription;
- (BbPatchDescription *)patchDescription;

@end


@interface BbPort (Encode)

- (BbDescription *)description;
- (BbConnectionDescription *)connectionDescription;
- (NSArray *)connections;

@end