//
//  UIView+Bb.h
//  Visual Cocoa for iOS
//
//  Created by Travis Henspeter on 5/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>

@interface UIView (Bb)

+ (CGPoint)centerForFrame:(CGRect)frame;
+ (CGRect)rect:(CGRect)rect withCenter:(CGPoint)center;
+ (CGFloat)roundFloat:(CGFloat)aFloat;
- (NSLayoutConstraint *)horizontalCenterConstraint:(CGFloat)horizontalCenter;
- (NSLayoutConstraint *)verticalCenterConstraint:(CGFloat)verticalCenter;
- (void)pinHeight:(CGFloat)height width:(CGFloat)width;

@end

#endif