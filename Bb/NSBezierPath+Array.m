//
//  NSBezierPath+Array.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/25/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSBezierPath+Array.h"

@implementation NSBezierPath (Array)

+ (NSBezierPath *)pathWithArray:(NSArray *)array
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
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:point];
    point.x = x2;
    point.y = y2;
    [path lineToPoint:point];
    [path setLineWidth:4];
    return path;
}

@end
