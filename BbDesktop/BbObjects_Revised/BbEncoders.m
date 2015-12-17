//
//  BbEncoders.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbEncoders.h"

@implementation BbObject (Encode)

- (BbDescription *)description
{
    if (!self.childObjects || self.childObjects.count == 0) {
        return [self objectDescription];
    }
    
    return [self patchDescription];
}

- (BbObjectDescription *)objectDescription
{
    return nil;
}
- (BbPatchDescription *)patchDescription
{
    return nil;
}

@end


@implementation BbPort (Encode)

- (BbDescription *)description
{
    if (!self.outputElement.observers || self.outputElement.observers.count < 1) {
        return nil;
    }
    
    if (self.outputElement.observers.count == 1) {
        return [self connectionDescription];
    }
    
    return nil;
    
}

- (BbConnectionDescription *)connectionDescription
{
    return nil;
}

- (NSArray *)connections
{
    return nil;
}

@end

