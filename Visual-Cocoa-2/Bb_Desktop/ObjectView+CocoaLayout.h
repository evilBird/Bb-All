//
//  ObjectView+CocoaLayout.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ObjectView.h"
@class BbDisplayConfiguration;

@interface ObjectView (CocoaLayout)

+ (NSPoint)position:(NSPoint)position forView:(NSView *)view inSuperview:(NSView *)superview;
+ (NSSize)spacerSizeForConfig:(BbDisplayConfiguration *)config;
+ (NSSize)portSize;
+ (NSSize)frameSizeForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text;
+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets;
+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text;
+ (CGFloat)widthForPortCount:(NSUInteger)portCount;
+ (CGFloat)roundFloat:(CGFloat)aFloat;

@end
