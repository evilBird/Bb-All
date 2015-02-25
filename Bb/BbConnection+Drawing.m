//
//  BbConnection+Drawing.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/25/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbConnection+Drawing.h"
#import "BbCocoaPatchView+Connections.h"
#import "BbCocoaPortView.h"
#import "BbPatch.h"

@implementation BbConnection (Drawing)

- (NSBezierPath *)bezierPath
{
    if (self.status == BbConnectionStatus_Dirty || self.status == BbConnectionStatus_NotConnected)
    {
        return nil;
    }
    
    NSArray *coordinates = [self pathCoordinates];
    
    if (!coordinates || coordinates.count != 4) {
        return nil;
    }
    
    CGFloat x1,y1,x2,y2;
    x1 = [coordinates[0] doubleValue];
    y1 = [coordinates[1] doubleValue];
    x2 = [coordinates[2] doubleValue];
    y2 = [coordinates[3] doubleValue];
    
    CGPoint point = CGPointMake(x1, y1);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:point];
    point.x = x2;
    point.y = y2;
    [path lineToPoint:point];
    
    [path setLineWidth:4];
    if (!self.selected) {
        [[NSColor blackColor]setStroke];
    }else if (self.selected){
        [[NSColor colorWithWhite:0.5 alpha:1]setStroke];
    }
    
    return path;
}

- (NSArray *)pathCoordinates
{
    if (self.status == BbConnectionStatus_Dirty || self.status == BbConnectionStatus_NotConnected) {
        return nil;
    }
    
    BbCocoaPortView * outletView = (BbCocoaPortView *)self.outlet.view;
    BbCocoaPortView * inletView = (BbCocoaPortView *)self.inlet.view;
    BbCocoaPatchView * patchView = (BbCocoaPatchView *)self.parent;
    
    CGRect outletRect = [patchView convertRect:outletView.bounds fromView:outletView];
    CGRect inletRect = [patchView convertRect:inletView.bounds fromView:inletView];
    
    NSArray *outletCoordinates = @[@(CGRectGetMidX(outletRect)),@(CGRectGetMidY(outletRect))];
    NSArray *inletCoordinates = @[@(CGRectGetMidX(inletRect)),@(CGRectGetMidY(inletRect))];
    NSArray *result = nil;
    if (inletCoordinates && outletCoordinates) {
        NSMutableArray *temp = [NSMutableArray array];
        [temp addObjectsFromArray:outletCoordinates];
        [temp addObjectsFromArray:inletCoordinates];
        result = [NSArray arrayWithArray:temp];
    }
    
    return result;
}

@end
