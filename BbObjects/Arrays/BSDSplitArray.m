//
//  BSDArraySplit.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDSplitArray.h"
#import "BSDNumberInlet.h"
#import "BSDArrayInlet.h"

@implementation BSDSplitArray

- (instancetype)initWithSplitIndex:(NSNumber *)splitIndex
{
    return [super initWithArguments:splitIndex];
}

- (instancetype)initWithArray:(NSArray *)array
{
    return [super initWithArguments:array];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"split array";
    self.remainderOutlet = [[BSDOutlet alloc]init];
    self.remainderOutlet.name = @"right";
    [self addPort:self.remainderOutlet];
    
    NSArray *splitIndex = arguments;
    if (splitIndex) {
        self.coldInlet.value = splitIndex;
    }else{
        self.coldInlet.value = @0;
    }
}

- (BSDInlet *)makeRightInlet
{
    BSDNumberInlet *numberInlet = [[BSDNumberInlet alloc]initCold];
    numberInlet.name = @"cold";
    return numberInlet;
}

- (BSDInlet *)makeLeftInlet
{
    BSDArrayInlet *inlet = [[BSDArrayInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.delegate = self;
    return inlet;
}

- (void)calculateOutput
{
    NSNumber *cold = self.coldInlet.value;
    if (!cold || ![cold isKindOfClass:[NSNumber class]]) {
        return;
    }
    
    NSUInteger i = cold.integerValue;
    NSArray *arr = self.hotInlet.value;
    if (!arr || ![arr isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableArray *array = [arr mutableCopy];
    
    if (array && i>0 && i<array.count + 1) {
        NSRange leftRange;
        leftRange.location = 0;
        leftRange.length = i;
        NSRange rightRange;
        rightRange.location = i;
        rightRange.length = array.count - i;
        
        NSArray *left = [array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:leftRange]];
        id leftOutput = nil;
        if (left.count == 1) {
            leftOutput = left.firstObject;
        }else{
            leftOutput = left.mutableCopy;
        }
        
        [self.mainOutlet output:leftOutput];
        
        NSArray *right = [array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:rightRange]];
        id rightOutput = nil;
        if (right.count == 1) {
            rightOutput = right.firstObject;
        }else{
            rightOutput = right.mutableCopy;
        }
        [self.remainderOutlet output:rightOutput];
        //[self.mainOutlet output:[array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:leftRange]]];
        //[self.remainderOutlet output:[array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:rightRange]]];
    }
}

- (void)test
{
    self.coldInlet.value = @[@(1),@(2),@(3),@(4),@(5)];
    self.hotInlet.value = @(3);
    self.hotInlet.value = @(4);
    self.hotInlet.value = @(5);
    self.hotInlet.value = @(0);
    self.hotInlet.value = @(-2);
}

@end
