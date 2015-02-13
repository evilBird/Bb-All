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

    if (self.view) {
        CGSize size = [self.view frame].size;
        desc.UISize = [NSValue valueWithSize:size];
        CGPoint center = [self.view center];
        desc.UICenter = [NSValue valueWithPoint:center];
        desc.UIPosition = @[@(center.x),@(center.y)];
    }else{
        desc.UIPosition = @[@(0),@(0)];
    }
    
    return desc;
}


@end
