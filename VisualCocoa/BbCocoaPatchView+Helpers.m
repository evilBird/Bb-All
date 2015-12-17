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
#import "NSMutableString+Bb.h"
#import "BbAbstraction.h"

@implementation BbCocoaPatchView (Helpers)

#pragma mark - helpers

- (void)moveEntityView:(BbCocoaEntityView *)entityView toPoint:(VCPoint)point
{
    CGFloat dx,dy;
    VCPoint myCenter = [self myCenter];
    dx = point.x - myCenter.x;
    dy = point.y - myCenter.y;
    [entityView.centerXConstraint autoRemove];
    [entityView.centerYConstraint autoRemove];
    entityView.centerXConstraint = [entityView autoAlignAxis:ALAxisVertical toSameAxisOfView:self withOffset:[VCView roundFloat:dx]];
    entityView.centerYConstraint = [entityView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-[VCView roundFloat:dy]];
    [entityView.centerXConstraint autoInstall];
    [entityView.centerYConstraint autoInstall];
#if TARGET_OS_IPHONE == 1
    [self setNeedsDisplay];
#else
    entityView.normalizedPosition = [self normalizePoint:point];
    [self setNeedsDisplay:YES];
    [self layoutSubtreeIfNeeded];
#endif
}

- (void)drawPathFromPortView:(BbCocoaPortView *)portView toPoint:(VCPoint)toPoint
{
    VCRect bounds = portView.bounds;
    VCRect senderBounds = [self convertRect:bounds fromView:portView];
    VCPoint point = CGPointMake(CGRectGetMidX(senderBounds), CGRectGetMidY(senderBounds));
    CGFloat x1,y1,x2,y2;
    x1 = point.x;
    y1 = point.y;
    x2 = toPoint.x;
    y2 = toPoint.y;
 #if TARGET_OS_IPHONE == 1
    [self setNeedsDisplay];
#else
    [self setNeedsDisplay:YES];
#endif
    self.drawThisConnection = @[@(x1),@(y1),@(x2),@(y2)];
}

- (VCSize)initOffsetObjectView:(BbCocoaObjectView *)view event:(VCEvent *)theEvent
{
    VCSize result;
    VCPoint objectCenter = [self scaleNormalizedPoint:view.normalizedPosition];
#if TARGET_OS_IPHONE == 0
    result.width = (theEvent.locationInWindow.x - objectCenter.x);
    result.height = (theEvent.locationInWindow.y - objectCenter.y);
#else
    UITouch *touch = [theEvent touchesForView:self].allObjects.lastObject;
    VCPoint loc = [touch locationInView:self];
    result.width = loc.x - objectCenter.x;
    result.height = loc.y - objectCenter.y;
#endif
    return result;
}

- (VCPoint)normalizePoint:(VCPoint)point
{
    CGFloat x,y;
    x = (point.x * 100.0)/self.intrinsicContentSize.width;
    y = (point.y * 100.0)/self.intrinsicContentSize.height;
    VCPoint normPoint = CGPointMake([VCView roundFloat:x], [VCView roundFloat:y]);
    return normPoint;
}

- (VCPoint)scaleNormalizedPoint:(VCPoint)point
{
    CGFloat x,y;
    x = point.x * 0.01 * self.intrinsicContentSize.width;
    y = point.y * 0.01 * self.intrinsicContentSize.height;
    
    VCPoint scaledPoint = CGPointMake([VCView roundFloat:x], [VCView roundFloat:y]);
    return scaledPoint;

}

- (VCPoint)offsetScaledPoint:(VCPoint)point
{
    VCPoint p = point;
    p.x -= kInitOffset.width;
    p.y -= kInitOffset.height;
    return p;
}

- (VCPoint)myCenter
{
    CGFloat x,y;
    x = self.intrinsicContentSize.width/2.0;
    y = self.intrinsicContentSize.height/2.0;
    VCPoint myCenter = CGPointMake([VCView roundFloat:x], [VCView roundFloat:y]);
    return myCenter;
}

- (NSArray *)selectedObjectViews
{
    NSMutableArray *selected = nil;
    for (id subview in self.subviews) {
        if ([subview respondsToSelector:@selector(selected)]) {
            if ([subview selected]){
                if (!selected){
                    selected = [NSMutableArray array];
                }
                
                [selected addObject:subview];
            }
        }
    }
    
    return selected;
}

- (NSString *)copySelected
{
    NSArray *selected = [self selectedObjectViews];
    NSMutableString *copied = [NSMutableString newDescription];
    NSUInteger i = 0;
    for (BbCocoaEntityView *view in selected) {
        BbObject *object = (BbObject *)[view entity];
        [copied appendThenNewLine:[object copyWithOffset:@[@(5),@(5)]]];
        i ++;
    }
    return copied;
    
}

- (void)pasteCopied:(NSString *)copied
{
    NSArray *descriptions = [copied componentsSeparatedByString:@"\n"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"length > 1"];
    NSArray *filtered = [descriptions filteredArrayUsingPredicate:pred];
    for (NSString *description in filtered) {
        [self addObjectWithText:description];
    }
}

- (void)abstractSelected
{
    NSArray *selectedObjects = [self selectedObjectViews];
    for (BbObject *object in selectedObjects) {
        [self.patch removeChildObject:object];
    }
    NSArray *selectedConnections = [self.patch selectedConnections];
    for (BbConnection *connection in selectedConnections) {
        [self.patch removeConnectionWithId:connection.connectionId];
    }
    
    BbAbstraction *abstraction = [[BbAbstraction alloc]init];
    for (BbObject *object in selectedObjects) {
        [abstraction addChildObject:object];
    }
    
    for (BbConnection *connection in selectedConnections) {
        if (![connection isDirty]) {
            if (!abstraction.connections) {
                abstraction.connections = [NSMutableDictionary dictionary];
            }
            [abstraction.connections setObject:connection forKey:connection.connectionId];
        }
    }
    
    [self.patch addChildObject:abstraction];
    [self addViewForObject:abstraction];
#if TARGET_OS_IPHONE == 0
    [self moveEntityView:(BbCocoaObjectView *)abstraction.view toPoint:NSPointFromCGPoint(CGPointMake(50, 50))];
    [(BbCocoaObjectView *)[abstraction view]setDisplayedText:@"abstract"];
#endif

}

@end
