//
//  BbGesture.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbBlockMatrix+Helpers.h"

typedef NS_ENUM(NSUInteger, BbGestureType) {
    BbGestureType_Tap           =   0,
    BbGestureType_LongPress     =   1,
    BbGestureType_SwipeLeft     =   2,
    BbGestureType_SwipeRight    =   3,
    BbGestureType_SwipeUp       =   4,
    BbGestureType_SwipeDown     =   5,
    BbGestureType_Pan           =   6,
    BbGestureNumTypes           =   7
};

@interface BbGesture : NSObject

+ (NSArray *) allGestureClasses;
+ (NSArray *) gesturePossibleEvaluators;
+ (BbGestureType) gestureType;
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