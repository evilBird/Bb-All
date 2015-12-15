//
//  BbBlockMatrix.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbBlockMatrix.h"

@interface BbBlockMatrix ()

@property (nonatomic,strong)            NSMutableArray          *elements;

@end

@implementation BbBlockMatrix

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    self = [super init];
    if ( self ) {
        _nRows = rows;
        _nCols = columns;
        [self commonInit];
    }
    return self;
}

- (void)setEvaluator:(BbBlockMatrixEvaluator)evaluator forElementAtRow:(NSUInteger)aRow column:(NSUInteger)aColumn
{
    NSAssert( nil != evaluator, @"Evaluation block is nil");
    [self validateRow:aRow column:aColumn];
    NSUInteger index = [self indexWithRow:aRow column:aColumn];
    self.elements[index] = evaluator;
}

- (void)setEvaluators:(NSArray *)evaluators forElementsInRow:(NSUInteger)aRow
{
    [self validateInputArray:evaluators];
    NSEnumerator *evalEnum = evaluators.objectEnumerator;
    for ( NSUInteger i = 0; i < self.nCols ; i ++ ) {
        [self setEvaluator:[evalEnum nextObject] forElementAtRow:aRow column:i];
    }
}

- (NSArray *) rowSumsByEvaluationInputArray:(NSArray *)inputArray
{
    [self validateInputArray:inputArray];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:inputArray.count];
    for ( NSUInteger i = 0; i < self.nRows; i ++ ) {
        NSArray *aRow = [self evaluateRow:i withInputArray:inputArray];
        NSAssert( nil != aRow, @"Invalid row evaluation output (nil)");
        NSAssert( aRow.count == inputArray.count, @"Invalid row evaluation output (length)");
        NSNumber *rowSum = [self arraySum:inputArray];
        NSAssert( nil != rowSum, @"Invalid row product (nil)");
        [results addObject:rowSum];
    }
    
    return results;
}

- (NSArray *) rowProductsByEvaluatingInputArray:(NSArray *)inputArray
{
    [self validateInputArray:inputArray];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:inputArray.count];
    for ( NSUInteger i = 0; i < self.nRows; i ++ ) {
        NSArray *aRow = [self evaluateRow:i withInputArray:inputArray];
        NSAssert( nil != aRow, @"Invalid row evaluation output (nil)");
        NSAssert( aRow.count == inputArray.count, @"Invalid row evaluation output (length)");
        NSNumber *rowProd = [self arrayProduct:aRow];
        NSAssert( nil != rowProd, @"Invalid row product (nil)");
        [results addObject:rowProd];
    }
    
    return results;
}

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

- (NSNumber *)arraySum:(NSArray *)array
{
    return [array valueForKeyPath:@"@sum.self"];
}

- (NSNumber *)arrayProduct:(NSArray *)array
{
    double resultValue = 1.0;
    for (NSNumber *element in array) {
        resultValue *= element.doubleValue;
    }
    
    return @(resultValue);
}

#pragma configuration

- (void)commonInit
{
    [self validateDimensions];
    NSUInteger numElements = ( self.nRows * self.nCols );
    self.elements = [NSMutableArray arrayWithCapacity:numElements];
    for ( NSUInteger i = 0; i < numElements ; i ++ ) {
        self.elements[i] = [BbBlockMatrix defaultEvaluator];
    }
}

#pragma mark - Helpers

+ (BbBlockMatrixEvaluator)defaultEvaluator
{
    return ^( id input ){
        return @(0);
    };
}

- (BbBlockMatrixEvaluator)getEvaluatorAtRow:(NSUInteger)aRow column:(NSUInteger)aColumn
{
    NSUInteger index = [self indexWithRow:aRow column:aColumn];
    return self.elements[index];
}

- (NSUInteger)indexWithRow:(NSUInteger)aRow column:(NSUInteger)aColumn
{
    return ( aRow * self.nCols + aColumn);
}

- (NSArray *)getElementsInRow:(NSUInteger)aRow
{
    NSUInteger firstIndex = [self indexWithRow:aRow column:0];
    NSUInteger length = self.nCols;
    NSRange elementsRange;
    elementsRange.location = firstIndex;
    elementsRange.length = length;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:elementsRange];
    return [self.elements objectsAtIndexes:indexSet];
}

#pragma mark - validation

- (BOOL)validateDimensions
{
    NSAssert(_nRows > 0,@"Invalid number of rows");
    NSAssert(_nCols > 0,@"Invalid number of columns");
    return YES;
}

- (BOOL)validateRow:(NSUInteger)aRow column:(NSUInteger)aColumn
{
    NSAssert( aRow < _nRows, @"Invalid row index");
    NSAssert( aColumn < _nCols, @"Invalid column index");
    return YES;
}

- (BOOL)validateInputArray:(NSArray *)inputArray
{
    NSAssert( nil != inputArray, @"Input array is invalid (nil)");
    NSAssert( inputArray.count == _nCols, @"Invalid input array (length)");
    return YES;
}

@end
