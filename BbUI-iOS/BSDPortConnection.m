//
//  BSDPortConnection.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPortConnection.h"
#import "BSDPortView.h"

@implementation BSDPortConnection

- (instancetype)initWithOwner:(BSDPortView *)portView target:(BSDPortView *)target
{
    self = [super init];
    if (self) {
        _owner = portView;
        _target = target;
    }
    
    return self;
}

+ (BSDPortConnection *)connectionWithOwner:(BSDPortView *)owner target:(BSDPortView *)target
{
    return [[BSDPortConnection alloc]initWithOwner:owner target:target];
}

- (CGPoint)origin
{
    return CGPointMake(CGRectGetMidX(self.owner.frame), CGRectGetMidY(self.owner.frame));
}

- (CGPoint)destination
{
    return CGPointMake(CGRectGetMidX(self.target.frame), CGRectGetMidY(self.target.frame));
}

@end
