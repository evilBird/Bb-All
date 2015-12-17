//
//  BbMatrix.m
//  
//
//  Created by Travis Henspeter on 12/16/15.
//
//

#import "BbMatrix.h"

@implementation BbMatrix

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

- (void)commonInit
{
    [self validateDimensions];
    NSUInteger numElements = ( self.nRows * self.nCols );
    self.elements = [NSMutableArray arrayWithCapacity:numElements];
    for ( NSUInteger i = 0; i < numElements ; i ++ ) {
        self.elements[i] = [self defaultElementValue];
    }
}

- (void) setValue:(id)value forElementAtRow:(NSUInteger)aRow column:(NSUInteger)aColumn
{
    NSAssert( nil != value, @"Element value is nil");
    [self validateRow:aRow column:aColumn];
    NSUInteger index = [self indexWithRow:aRow column:aColumn];
    self.elements[index] = value;
}

- (void) setValues:(NSArray *)values forElementsInRow:(NSUInteger)aRow
{
    [self validateInputArray:values];
    NSEnumerator *valEnum = values.objectEnumerator;
    for ( NSUInteger i = 0; i < self.nCols ; i ++ ) {
        [self setValue:[valEnum nextObject] forElementAtRow:aRow column:i];
    }
}

- (NSArray *) evaluateRow:(NSUInteger)aRow withInputArray:(NSArray *)inputArray
{
    return nil;
}

- (NSArray *) rowSumsByEvaluationInputArray:(NSArray *)inputArray
{
    [self validateInputArray:inputArray];
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:inputArray.count];
    for ( NSUInteger i = 0; i < self.nRows; i ++ ) {
        NSArray *aRow = [self evaluateRow:i withInputArray:inputArray];
        NSAssert( nil != aRow, @"Invalid row evaluation output (nil)");
        NSAssert( aRow.count == inputArray.count, @"Invalid row evaluation output (length)");
        NSNumber *rowSum = [BbMatrix arraySum:aRow];
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
        NSNumber *rowProd = [BbMatrix arrayProduct:aRow];
        NSAssert( nil != rowProd, @"Invalid row product (nil)");
        [results addObject:rowProd];
    }
    
    return results;
}

#pragma mark - Helpers

- (NSUInteger)indexWithRow:(NSUInteger)aRow column:(NSUInteger)aColumn
{
    return ( aRow * self.nCols + aColumn);
}

- (id)getValueForElementAtRow:(NSUInteger)aRow column:(NSUInteger)aColumn
{
    NSUInteger index = [self indexWithRow:aRow column:aColumn];
    return self.elements[index];
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

+ (NSNumber *)arraySum:(NSArray *)array
{
    return [array valueForKeyPath:@"@sum.self"];
}

+ (NSNumber *)arrayProduct:(NSArray *)array
{
    double resultValue = 1.0;
    for (NSNumber *element in array) {
        resultValue *= element.doubleValue;
    }
    
    return @(resultValue);
}

- (id)defaultElementValue
{
    return @(0);
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
