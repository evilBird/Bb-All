//
//  BbMatrix.h
//  
//
//  Created by Travis Henspeter on 12/16/15.
//
//

#import <Foundation/Foundation.h>

@interface BbMatrix : NSObject

- (instancetype) initWithRows:(NSUInteger)rows columns:(NSUInteger)columns;

@property (nonatomic)                       NSUInteger                  nRows;
@property (nonatomic)                       NSUInteger                  nCols;
@property (nonatomic,strong)                NSMutableArray              *elements;

- (void) commonInit;

- (void) setValue:(id)value forElementAtRow:(NSUInteger)aRow column:(NSUInteger)aColumn;
- (void) setValues:(NSArray *)values forElementsInRow:(NSUInteger)aRow;

- (id) getValueForElementAtRow:(NSUInteger)aRow column:(NSUInteger)aColumn;
- (id) defaultElementValue;

- (NSArray *) rowProductsByEvaluatingInputArray:(NSArray *)inputArray;
- (NSArray *) rowSumsByEvaluationInputArray:(NSArray *)inputArray;

- (NSArray *) evaluateRow:(NSUInteger)aRow withInputArray:(NSArray *)inputArray;
+ (NSNumber *) arraySum:(NSArray *)array;
+ (NSNumber *) arrayProduct:(NSArray *)array;

- (NSUInteger) indexWithRow:(NSUInteger)aRow column:(NSUInteger)aColumn;
- (NSArray *) getElementsInRow:(NSUInteger)aRow;

- (BOOL) validateDimensions;
- (BOOL) validateRow:(NSUInteger)aRow column:(NSUInteger)aColumn;
- (BOOL) validateInputArray:(NSArray *)inputArray;

@end
