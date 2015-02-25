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
    if (self.status == BbConnectionStatus_Dirty)
    {
        return nil;
    }
    
    NSArray *coordinates = [self pathCoordinates];
    
    if (!coordinates || coordinates.count != 4) {
        return nil;
    }
    
    NSBezierPath *path = [NSBezierPath pathWithArray:coordinates];
    
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
    BbCocoaPatchView * patchView = (BbCocoaPatchView *)[(BbPatch *)self.parent view];
    
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

- (BOOL)hitTest:(NSPoint)point
{
    NSArray *array = [self pathCoordinates];
    
    CGFloat x1,y1,x2,y2; //Path coordinates
    
    CGFloat x3,y3;//Point we'll hit test
    
    CGFloat dx; //Distance between min & max X of path
    CGFloat dy; //Distance between min & max Y of path
    CGFloat dx1; //Distance between point.x and min X of path
    CGFloat m,b; //Slope and intercept coefficients
    
    if (!array || array.count == 0) {
        return NO;
    }
    
    x1 = [array[0] doubleValue];
    y1 = [array[1] doubleValue];
    x2 = [array[2] doubleValue];
    y2 = [array[3] doubleValue];
    x3 = point.x;
    y3 = point.y;
    
    if (x2 > x1) {
        if (!(x2 >= x3) || !(x3>= x1)) {
            //point.x does not lie within the path's horizontal range
            return NO;
        }
        
        dx = x2 - x1;
        dy = y2 - y1;
        b = y1;
        dx1 = x3 - x1;
        
    }else{
        if (!(x1 >= x3) || !(x3>= x2)) {
            //point.x does not lie within the path's horizontal range
            return NO;
        }
        
        dx = x1 - x2;
        dy = y1 - y2;
        b = y2;
        dx1 = x3 - x2;
    }
    
    if (y2 > y1) {
        if (!(y2>=y3) || !(y3>=y1)) {
            //point.y does not lie within the path's vertical range
            return NO;
        }
    }else{
        if (!(y1>=y3) || !(y3>=y2)) {
            //point.y does not lie within the path's vertical range
            return NO;
        }
    }
    
    m = dy/dx; //path slope
    
    CGFloat yhat = m * dx1 + b; //predicted point.y given point.x and linear model representing the path
    CGFloat error = fabs(yhat - y3); //prediction error
    CGFloat nerror = error/fabs(m); //ratio of dx1/dx. Values approaching 1 indicate that dx may be too small to make an accurate prediction for y, so we'll correct our error threshold appropriately.
    
    //NSLog(@"error = %.2f\nnerror = %.2f",error,nerror);
    
    if (nerror < 8) {
        return YES;
    }
    
    return NO;
}

@end
