//
//  BbObject+Encoder.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+Encoder.h"
#import "BbParsers.h"
#import "BbObject+Tests.h"
#import "NSView+Bb.h"
#import "BbCocoaEntityView.h"

@implementation BbObject (Encoder)

- (BbDescription *)encodeDescription
{
    return [self encodeObjectDescription];
}

- (BbPatchDescription *)encodePatchDescription
{
    return nil;
}

- (BbObjectDescription *)encodeObjectDescription
{
    BbObjectDescription *desc = [BbObjectDescription new];
    desc.BbObjectType = [self className];
    desc.BbObjectArgs = [self creationArguments].mutableCopy;
    desc.UIType = [[self class] UIType];
    if (self.view) {
        desc.UIPosition = self.position.mutableCopy;
    }else{
        desc.UIPosition = @[@(50),@(50)];
    }
    
    return desc;
}


@end
