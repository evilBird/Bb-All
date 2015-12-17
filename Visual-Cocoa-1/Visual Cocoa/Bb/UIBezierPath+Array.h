//
//  UIBezierPath+Array.h
//  Visual Cocoa for iOS
//
//  Created by Travis Henspeter on 5/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>

@interface UIBezierPath (Array)

+ (UIBezierPath *)pathWithArray:(NSArray *)array;

@end

#endif