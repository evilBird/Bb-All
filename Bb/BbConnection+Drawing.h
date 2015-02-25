//
//  BbConnection+Drawing.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/25/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbConnection.h"

typedef NSArray* (^BbConnectionCalculatePathBlock)(void);

@interface BbConnection (Drawing)

- (NSArray *)pathCoordinates;
- (NSBezierPath *)bezierPath;

@end
