//
//  BbBlockMatrix+Helpers.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbBlockMatrix+Helpers.h"

@implementation BbBlockMatrix (Helpers)

+ (BbBlockMatrixEvaluator)evaluatorWithExpression:(NSString *)expression
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:expression,value];
        NSNumber *result = ( [predicate evaluateWithObject:value] ) ? @(1) : @(0);
        return result;
    };
    return evaluator;
}

+ (BbBlockMatrixEvaluator)evaluatorWithMinValue:(double)minValue
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        double myValue = [(NSNumber *)value doubleValue];
        NSNumber *result = ( myValue >= minValue ) ? @(1) : @(0);
        return result;
    };
    return evaluator;
}

+ (BbBlockMatrixEvaluator)evaluatorWithMaxValue:(double)maxValue
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        double myValue = [(NSNumber *)value doubleValue];
        NSNumber *result = ( myValue <= maxValue ) ? @(1) : @(0);
        return result;
    };
    return evaluator;
}

+ (BbBlockMatrixEvaluator)evaluatorWithExactValue:(double)exactValue
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        double myValue = [(NSNumber *)value doubleValue];
        NSNumber *result = ( myValue == exactValue ) ? @(1) : @(0);
        return result;
    };
    return evaluator;
}

+ (BbBlockMatrixEvaluator)evaluatorWithMinAbsValue:(double)minAbsValue
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        double myValue = fabs([(NSNumber *)value doubleValue]);
        NSNumber *result = ( myValue >= minAbsValue ) ? @(1) : @(0);
        return result;
    };
    return evaluator;
}

+ (BbBlockMatrixEvaluator)evaluatorWithMaxAbsValue:(double)maxAbsValue
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        double myValue = fabs([(NSNumber *)value doubleValue]);
        NSNumber *result = ( myValue <= maxAbsValue ) ? @(1) : @(0);
        return result;
    };
    return evaluator;
}

+ (BbBlockMatrixEvaluator)evaluatorTrue
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        return @(1);
    };
    return evaluator;
}

+ (BbBlockMatrixEvaluator)evaluatorFalse
{
    BbBlockMatrixEvaluator evaluator = ^( id value){
        return @(0);
    };
    return evaluator;
}

@end
