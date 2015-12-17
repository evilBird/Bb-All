//
//  BbBlockMatrix.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbBlockMatrix+Helpers.h"

@interface BbBlockMatrix ()

@end

@implementation BbBlockMatrix


#pragma mark - Private
#pragma mark - Evaluation

- (NSArray *) evaluateRow:(NSUInteger)aRow withInputArray:(NSArray *)inputArray
{
    NSEnumerator *rowElementEnumerator = [self getElementsInRow:aRow].objectEnumerator;
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:inputArray.count];
    for (id inputVal in inputArray ) {
        BbBlockMatrixEvaluator evaluator = [rowElementEnumerator nextObject];
        NSNumber *result = evaluator(inputVal);
        NSAssert( nil != result, @"Invalid evaluation block return value");
        [results addObject:result];
    }
    
    return results;
}

#pragma mark - Helpers

- (id)defaultElementValue
{
    return [BbBlockMatrix evaluatorFalse];
}


@end
