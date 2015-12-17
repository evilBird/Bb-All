//
//  NSBezierPath+Array.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/25/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE == 0

#import <AppKit/AppKit.h>

@interface NSBezierPath (Array)

+ (NSBezierPath *)pathWithArray:(NSArray *)array;

@end

#endif
