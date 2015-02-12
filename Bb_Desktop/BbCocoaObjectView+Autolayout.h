//
//  BbCocoaObjectView+Autolayout.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaObjectView.h"

@interface BbCocoaObjectView (Autolayout)

- (NSArray *)spacerViewsForPortViews:(NSArray *)portViews;
- (NSArray *)portViewsWithCount:(NSUInteger)count;
- (void)layoutPortviews:(NSArray *)portViews spacers:(NSArray *)spacers isTopRow:(BOOL)isTopRow;
- (void)setHorizontalCenter:(CGFloat)horizontalCenter;
- (void)setVerticalCenter:(CGFloat)verticalCenter;
- (void)setWidth:(CGFloat)width height:(CGFloat)height;


+ (NSPoint)position:(NSPoint)position forView:(NSView *)view inSuperview:(NSView *)superview;
+ (NSSize)spacerSizeForConfig:(BbObjectViewConfiguration *)config;
+ (NSSize)portSize;
+ (NSSize)frameSizeForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text;
+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets;
+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text;
+ (CGFloat)widthForPortCount:(NSUInteger)portCount;
+ (CGFloat)roundFloat:(CGFloat)aFloat;

@end
