//
//  UIView+Bb.m
//  Visual Cocoa for iOS
//
//  Created by Travis Henspeter on 5/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "UIView+Bb.h"
#if TARGET_OS_IPHONE == 1

@implementation UIView (Bb)

+ (CGPoint)centerForFrame:(CGRect)frame
{
    return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
}

+ (CGFloat)roundFloat:(CGFloat)aFloat
{
    return (CGFloat)(NSInteger)(aFloat + 0.5);
}

+ (CGRect)rect:(CGRect)rect withCenter:(CGPoint)center
{
    CGPoint currentCenter = [UIView centerForFrame:rect];
    CGFloat dx = currentCenter.x - center.x;
    CGFloat dy = currentCenter.y - center.y;
    return CGRectOffset(rect, dx, dy);
}

- (NSLayoutConstraint *)horizontalCenterConstraint:(CGFloat)horizontalCenter
{
    if (!self.superview) {
        return nil;
    }
    
    NSLayoutConstraint *constraint = nil;
    CGRect superViewBounds = self.superview.bounds;
    CGFloat superViewWidth = CGRectGetWidth(superViewBounds);
    CGFloat multiplier = (horizontalCenter/superViewWidth) * 2.0f;
    CGFloat m = [UIView roundFloat:multiplier];
    constraint = [NSLayoutConstraint
                  constraintWithItem:self
                  attribute:NSLayoutAttributeCenterX
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.superview
                  attribute:NSLayoutAttributeCenterX
                  multiplier:m
                  constant:0.0];
    return constraint;
}

- (NSLayoutConstraint *)verticalCenterConstraint:(CGFloat)verticalCenter
{
    if (!self.superview) {
        return nil;
    }
    
    NSLayoutConstraint *constraint = nil;
    CGRect superViewBounds = self.superview.bounds;
    CGFloat superViewHeight = CGRectGetHeight(superViewBounds);
    CGFloat multiplier = (verticalCenter/superViewHeight) * 2.0f;
    CGFloat m = [UIView roundFloat:multiplier];
    constraint = [NSLayoutConstraint
                  constraintWithItem:self
                  attribute:NSLayoutAttributeCenterY
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.superview
                  attribute:NSLayoutAttributeCenterY
                  multiplier:m
                  constant:0.0];
    return constraint;
}

- (void)pinHeight:(CGFloat)height width:(CGFloat)width
{
    if (!self.superview) {
        return;
    }
    
    NSLayoutConstraint *constraint = nil;
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self
                  attribute:NSLayoutAttributeHeight
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.superview
                  attribute:NSLayoutAttributeHeight
                  multiplier:0.0
                  constant:width];
    [self.superview addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.superview
                  attribute:NSLayoutAttributeWidth
                  multiplier:0.0
                  constant:width];
    [self.superview addConstraint:constraint];
}

@end

#endif