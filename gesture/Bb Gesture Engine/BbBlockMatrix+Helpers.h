//
//  BbBlockMatrix+Helpers.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbBlockMatrix.h"

@interface BbBlockMatrix (Helpers)

+ (BbBlockMatrixEvaluator)evaluatorWithExpression:(NSString *)expression;
+ (BbBlockMatrixEvaluator)evaluatorWithMinValue:(double)minValue;
+ (BbBlockMatrixEvaluator)evaluatorWithMaxValue:(double)maxValue;
+ (BbBlockMatrixEvaluator)evaluatorWithMinAbsValue:(double)minAbsValue;
+ (BbBlockMatrixEvaluator)evaluatorWithMaxAbsValue:(double)maxAbsValue;
+ (BbBlockMatrixEvaluator)evaluatorWithExactValue:(double)exactValue;
+ (BbBlockMatrixEvaluator)evaluatorTrue;
+ (BbBlockMatrixEvaluator)evaluatorFalse;


@end
