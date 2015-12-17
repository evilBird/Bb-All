//
//  BbCocoaInletView.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaInletView.h"

@implementation BbCocoaInletView

- (VCSize)intrinsicContentSize
{
#if TARGET_OS_IPHONE
    VCSize size = CGSizeMake(85, kDefaultCocoaObjectViewHeight);
#else
    VCSize size = NSSizeFromCGSize(CGSizeMake(85, kDefaultCocoaObjectViewHeight));
#endif
    return size;
}

@end

@implementation BbCocoaOutletView

- (VCSize)intrinsicContentSize
{
#if TARGET_OS_IPHONE
    VCSize size = CGSizeMake(85, kDefaultCocoaObjectViewHeight);
#else
    VCSize size = NSSizeFromCGSize(CGSizeMake(85, kDefaultCocoaObjectViewHeight));
#endif
    return size;
}

@end