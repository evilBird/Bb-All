//
//  NSObject+TypeConversion.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/13/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (TypeConversion)

+ (BOOL)methodSignature:(NSMethodSignature *)methodSignature argumentAtIndexReturnsRect:(NSUInteger)index;
+ (CGRect)rectFromObjectArg:(id)objectArg;

@end
