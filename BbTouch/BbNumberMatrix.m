//
//  BbNumberMatrix.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbNumberMatrix.h"

@implementation BbNumberMatrix

- (NSArray *) evaluateRow:(NSUInteger)aRow withInputArray:(NSArray *)inputArray
{
    NSEnumerator *rowElementEnumerator = [self getElementsInRow:aRow].objectEnumerator;
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:inputArray.count];
    for (NSNumber *inputVal in inputArray ) {
        NSNumber *element = [rowElementEnumerator nextObject];
        double product = ( inputVal.doubleValue * element.doubleValue );
        [results addObject:@(product)];
    }
    
    return results;
}

@end
