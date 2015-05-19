//
//  BbCocoaInletView.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaInletView.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define VCView          UIView
#define VCColor         UIColor
#define VCPoint         CGPoint
#define VCTextField     UITextField
#define VCRect          CGRect
#define VCSize          CGSize
#else
#import <AppKit/AppKit.h>
#define VCView          UIView
#define VCColor         UIColor
#define VCPoint         CGPoint
#define VCTextField     UITextField
#define VCRect          CGRect
#define VCSize          NSSize
#endif

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