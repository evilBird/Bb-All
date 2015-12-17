//
//  BbConnection+Drawing.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/25/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbConnection.h"
#if TARGET_OS_IPHONE == 1
#import "UIBezierPath+Array.h"
#define VCBezierPath    UIBezierPath
#else
#import "NSBezierPath+Array.h"
#define VCBezierPath    NSBezierPath
#endif
//@class VCBezierPath;
typedef NSArray* (^BbConnectionCalculatePathBlock)(void);

@interface BbConnection (Drawing)

- (NSArray *)pathCoordinates;
- (VCBezierPath *)bezierPath;
- (BOOL)hitTest:(CGPoint)point;

@end
