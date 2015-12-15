//
//  BbBlockMatrix.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSNumber* (^BbBlockMatrixEvaluator) (id input);

@interface BbBlockMatrix : NSObject

- (instancetype) initWithRows:(NSUInteger)rows columns:(NSUInteger)columns;

- (void) setEvaluator:(BbBlockMatrixEvaluator)evaluator forElementAtRow:(NSUInteger)aRow column:(NSUInteger)aColumn;
- (void) setEvaluators:(NSArray *)evaluators forElementsInRow:(NSUInteger)aRow;
- (NSArray *)rowProductsByEvaluatingInputArray:(NSArray *)inputArray;
- (NSArray *)rowSumsByEvaluationInputArray:(NSArray *)inputArray;

@property (nonatomic)               NSUInteger                  nRows;
@property (nonatomic)               NSUInteger                  nCols;

@end
