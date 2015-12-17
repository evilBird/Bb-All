//
//  NSView+Bb.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Bb)

+ (CGPoint)centerForFrame:(CGRect)frame;
+ (CGRect)rect:(CGRect)rect withCenter:(CGPoint)center;
+ (CGFloat)roundFloat:(CGFloat)aFloat;
- (NSLayoutConstraint *)horizontalCenterConstraint:(CGFloat)horizontalCenter;
- (NSLayoutConstraint *)verticalCenterConstraint:(CGFloat)verticalCenter;
- (void)pinHeight:(CGFloat)height width:(CGFloat)width;

@end
