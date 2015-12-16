//
//  BbGesture.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbBlockMatrix+Helpers.h"

@interface BbGesture : NSObject

+ (NSArray *) allGestureClasses;
+ (NSArray *) gesturePossibleEvaluators;
+ (BbBlockMatrix *) gesturePossibleEvaluationMatrix;

@end

@interface BbTapGesture : BbGesture

@end

@interface BbLongPressGesture : BbGesture

@end

@interface BbSwipeLeftGesture : BbGesture

@end

@interface BbSwipeRightGesture : BbGesture

@end

@interface BbSwipeUpGesture : BbGesture

@end

@interface BbSwipeDownGesture : BbGesture

@end

@interface BbPanGesture : BbGesture

@end