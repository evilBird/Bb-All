//
//  BbCocoaPatchView+Helpers.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView+Helpers.h"
#import "BbCocoaObjectView.h"
#import "BbCocoaPortView.h"

@implementation BbCocoaPatchView (Helpers)

#pragma mark - helpers

- (void)moveEntityView:(BbCocoaEntityView *)entityView toPoint:(NSPoint)point
{
    CGFloat dx,dy;
    NSPoint myCenter = [self myCenter];
    dx = point.x - myCenter.x;
    dy = point.y - myCenter.y;
    [entityView.centerXConstraint autoRemove];
    [entityView.centerYConstraint autoRemove];
    entityView.centerXConstraint = [entityView autoAlignAxis:ALAxisVertical toSameAxisOfView:self withOffset:[NSView roundFloat:dx]];
    entityView.centerYConstraint = [entityView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-[NSView roundFloat:dy]];
    [entityView.centerXConstraint autoInstall];
    [entityView.centerYConstraint autoInstall];
    entityView.normalizedPosition = [self normalizePoint:point];
    [self setNeedsDisplay:YES];
    [self layoutSubtreeIfNeeded];
}

- (void)drawPathFromPortView:(BbCocoaPortView *)portView toPoint:(NSPoint)toPoint
{
    CGRect bounds = portView.bounds;
    CGRect senderBounds = [self convertRect:bounds fromView:portView];
    CGPoint point = CGPointMake(CGRectGetMidX(senderBounds), CGRectGetMidY(senderBounds));
    CGFloat x1,y1,x2,y2;
    x1 = point.x;
    y1 = point.y;
    x2 = toPoint.x;
    y2 = toPoint.y;
    self.drawThisConnection = @[@(x1),@(y1),@(x2),@(y2)];
    [self setNeedsDisplay:YES];
}

- (NSSize)initOffsetObjectView:(BbCocoaObjectView *)view event:(NSEvent *)theEvent
{
    NSSize result;
    NSPoint objectCenter = [self scaleNormalizedPoint:view.normalizedPosition];
    result.width = (theEvent.locationInWindow.x - objectCenter.x);
    result.height = (theEvent.locationInWindow.y - objectCenter.y);
    return result;
}

- (NSPoint)normalizePoint:(NSPoint)point
{
    CGFloat x,y;
    x = (point.x * 100.0)/self.intrinsicContentSize.width;
    y = (point.y * 100.0)/self.intrinsicContentSize.height;
    CGPoint normPoint = CGPointMake([NSView roundFloat:x], [NSView roundFloat:y]);
    return NSPointFromCGPoint(normPoint);
}

- (NSPoint)scaleNormalizedPoint:(NSPoint)point
{
    CGFloat x,y;
    x = point.x * 0.01 * self.intrinsicContentSize.width;
    y = point.y * 0.01 * self.intrinsicContentSize.height;
    CGPoint scaledPoint = CGPointMake([NSView roundFloat:x], [NSView roundFloat:y]);
    return NSPointFromCGPoint(scaledPoint);
}

- (NSPoint)offsetScaledPoint:(NSPoint)point
{
    NSPoint p = point;
    p.x -= kInitOffset.width;
    p.y -= kInitOffset.height;
    return p;
}

- (NSPoint)myCenter
{
    CGFloat x,y;
    x = self.intrinsicContentSize.width/2.0;
    y = self.intrinsicContentSize.height/2.0;
    CGPoint myCenter = CGPointMake([NSView roundFloat:x], [NSView roundFloat:y]);
    return NSPointFromCGPoint(myCenter);
}

@end
