//
//  BbCocoaInletView.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaInletView.h"

@implementation BbCocoaInletView

- (NSSize)intrinsicContentSize
{
    NSSize size = NSSizeFromCGSize(CGSizeMake(kDefaultCocoaObjectViewWidth, kDefaultCocoaObjectViewHeight));
    return size;
}

@end

@implementation BbCocoaOutletView

- (NSSize)intrinsicContentSize
{
    NSSize size = NSSizeFromCGSize(CGSizeMake(kDefaultCocoaObjectViewWidth, kDefaultCocoaObjectViewHeight));
    return size;
}

@end