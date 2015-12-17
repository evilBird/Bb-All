//
//  NSView+Bb.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE == 0
#import <AppKit/AppKit.h>
@interface NSView (Bb)


+ (CGPoint)centerForFrame:(CGRect)frame;
+ (CGRect)rect:(CGRect)rect withCenter:(CGPoint)center;
+ (CGFloat)roundFloat:(CGFloat)aFloat;
- (NSLayoutConstraint *)horizontalCenterConstraint:(CGFloat)horizontalCenter;
- (NSLayoutConstraint *)verticalCenterConstraint:(CGFloat)verticalCenter;
- (void)pinHeight:(CGFloat)height width:(CGFloat)width;

@end
#endif