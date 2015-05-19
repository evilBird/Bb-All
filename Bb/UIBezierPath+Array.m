//
//  UIBezierPath+Array.m
//  Visual Cocoa for iOS
//
//  Created by Travis Henspeter on 5/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//
#import "UIBezierPath+Array.h"

#if TARGET_OS_IPHONE

@implementation UIBezierPath (Array)

+ (UIBezierPath *)pathWithArray:(NSArray *)array
{
    if (!array || array.count != 4) {
        return nil;
    }
    
    CGFloat x1,y1,x2,y2;
    x1 = [array[0] doubleValue];
    y1 = [array[1] doubleValue];
    x2 = [array[2] doubleValue];
    y2 = [array[3] doubleValue];
    
    CGPoint point = CGPointMake(x1, y1);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    point.x = x2;
    point.y = y2;
    
    [path addLineToPoint:point];
    [path setLineWidth:4];
    return path;
}

@end

#endif