//
//  BbGesture.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbGesture.h"
#import "NSInvocation+Bb.h"

static NSUInteger   kGesturePossibleMatrixColumns = 3;
static NSString     *kGesturePossibleEvaluatorSelector = @"gesturePossibleEvaluators";

@implementation BbGesture

+ (NSArray *)allGestureClasses
{
    NSArray *classes = @[
                       NSStringFromClass([BbTapGesture class]),
                       NSStringFromClass([BbLongPressGesture class]),
                       NSStringFromClass([BbSwipeLeftGesture class]),
                       NSStringFromClass([BbSwipeRightGesture class]),
                       NSStringFromClass([BbSwipeUpGesture class]),
                       NSStringFromClass([BbSwipeDownGesture class]),
                       NSStringFromClass([BbPanGesture class])
                       ];
    return classes;
}

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorTrue],[BbBlockMatrix evaluatorTrue],[BbBlockMatrix evaluatorTrue]];
}

+ (BbBlockMatrix *) gesturePossibleEvaluationMatrix
{
    NSArray *gestureClasses = [BbGesture allGestureClasses];

    BbBlockMatrix *evaluationMatrix = [[BbBlockMatrix alloc]initWithRows:gestureClasses.count columns:kGesturePossibleMatrixColumns];
    
    for (NSString *aGestureClass in gestureClasses) {
        
        NSUInteger row = [gestureClasses indexOfObject:aGestureClass];
        NSArray *evaluators = [NSInvocation doClassMethod:aGestureClass
                                             selectorName:kGesturePossibleEvaluatorSelector
                                                     args:nil];
        [evaluationMatrix setEvaluators:evaluators forElementsInRow:row];
    }
    
    return evaluationMatrix;
}

@end

@implementation BbTapGesture

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorWithMaxValue:0.2],
             [BbBlockMatrix evaluatorWithMaxValue:0.01],
             [BbBlockMatrix evaluatorWithMaxValue:0.01]
             ];
}

@end

@implementation BbLongPressGesture

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorWithMinValue:0.5],
             [BbBlockMatrix evaluatorWithMaxValue:0.01],
             [BbBlockMatrix evaluatorWithMaxValue:0.01]
             ];
}

@end

@implementation BbSwipeLeftGesture

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorWithMaxValue:0.25],
             [BbBlockMatrix evaluatorWithMaxValue:-0.01],
             [BbBlockMatrix evaluatorWithMaxAbsValue:0.02]
             ];
}

@end

@implementation BbSwipeRightGesture

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorWithMaxValue:0.25],
             [BbBlockMatrix evaluatorWithMinValue:0.01],
             [BbBlockMatrix evaluatorWithMaxAbsValue:0.02]
             ];
}

@end

@implementation BbSwipeUpGesture

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorWithMaxValue:0.25],
             [BbBlockMatrix evaluatorWithMaxAbsValue:0.02],
             [BbBlockMatrix evaluatorWithMaxValue:-0.01]
             ];
}

@end

@implementation BbSwipeDownGesture

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorWithMaxValue:0.25],
             [BbBlockMatrix evaluatorWithMaxAbsValue:0.02],
             [BbBlockMatrix evaluatorWithMinValue:0.01]
             ];
}

@end

@implementation BbPanGesture

+ (NSArray *) gesturePossibleEvaluators
{
    return @[[BbBlockMatrix evaluatorTrue],
             [BbBlockMatrix evaluatorWithMinAbsValue:0.01],
             [BbBlockMatrix evaluatorWithMinAbsValue:0.01]
             ];
}

@end