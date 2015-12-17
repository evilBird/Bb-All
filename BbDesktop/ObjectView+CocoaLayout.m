//
//  ObjectView+CocoaLayout.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ObjectView+CocoaLayout.h"
#import <Cocoa/Cocoa.h>

static CGFloat kPortWidth = 24.0f;
static CGFloat kPortHeight = 12.0f;
static CGFloat kMinSpacerWidth = 10.0f;
static CGFloat kSpacerHeight = 20.0f;

@implementation ObjectView (CocoaLayout)

+ (NSPoint)position:(NSPoint)position forView:(NSView *)view inSuperview:(NSView *)superview
{
    return [view convertPoint:position fromView:superview];
}

+ (NSSize)spacerSizeForConfig:(BbDisplayConfiguration *)config
{
    CGFloat logicalSpacerWidthTop,logicalSpacerWidthBottom = 0.0;
    
    if (config.inlets > 1) {
        logicalSpacerWidthTop = (config.frame.size.width - 2 - (config.inlets * config.portSize.width))/(config.inlets - 1);
    }
    if (config.outlets > 1) {
        logicalSpacerWidthBottom = (config.frame.size.width - 2 - (config.outlets * config.portSize.width))/(config.outlets - 1);
    }
    
    CGFloat logicalSpacerWidth = 0.0;
    if (logicalSpacerWidthBottom > logicalSpacerWidthTop) {
        logicalSpacerWidth = logicalSpacerWidthBottom;
    }else if (logicalSpacerWidthTop > logicalSpacerWidthBottom){
        logicalSpacerWidth = logicalSpacerWidthTop;
    }
    
    CGFloat finalSpacerWidth = 0.0f;
    if (logicalSpacerWidth>kMinSpacerWidth) {
        finalSpacerWidth = logicalSpacerWidth;
    }else{
        finalSpacerWidth = kMinSpacerWidth;
    }
    
    NSSize result = NSMakeSize(finalSpacerWidth, kSpacerHeight);
    return result;
}

+ (NSSize)portSize
{
    return NSSizeFromCGSize(CGSizeMake(kPortWidth, kPortHeight));
}

+ (NSSize)frameSizeForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text
{
    NSSize result;
    result.width = [ObjectView widthForInlets:inlets outlets:outlets text:text];
    result.height = (kPortHeight * 2.0) + kSpacerHeight + 2;
    return result;
}

+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets
{
    CGFloat topWidth = [ObjectView widthForPortCount:inlets] + 2;
    CGFloat bottomWidth = [ObjectView widthForPortCount:outlets] + 2;
    if (topWidth>=bottomWidth) {
        return topWidth;
    }else{
        return bottomWidth;
    }
}

+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text
{
    CGFloat portBasedWidth = [ObjectView widthForInlets:inlets outlets:outlets];
    CGSize textBasedSize = [text sizeWithAttributes:[BbDisplayConfiguration textAttributes]];
    CGFloat textBasedWidth = [ObjectView roundFloat:(textBasedSize.width + kPortWidth + 2)];
    
    if (portBasedWidth > textBasedWidth) {
        return portBasedWidth;
    }else{
        return textBasedWidth;
    }
}

+ (CGFloat)widthForPortCount:(NSUInteger)portCount
{
    if (portCount == 0) {
        return 0;
    }
    return (CGFloat)portCount * kPortWidth + ((CGFloat)(portCount - 1) * kPortWidth);
}

+ (CGFloat)roundFloat:(CGFloat)aFloat
{
    return (CGFloat)(NSInteger)(aFloat + 0.5);
}

@end
