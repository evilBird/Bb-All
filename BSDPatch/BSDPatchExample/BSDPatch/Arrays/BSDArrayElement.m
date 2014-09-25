//
//  BSDArrayElement.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayElement.h"
#import "BSDCreate.h"

@implementation BSDArrayElement

- (instancetype)initWithArray:(NSArray *)array
{
    return [super initWithArguments:array];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"array element";
    NSArray *array = arguments;
    if (array) {
        self.coldInlet.value = array;
    }else{
        self.coldInlet.value = nil;
    }
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDNumberInlet alloc]initHot];
    inlet.name = @"hot";
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

- (void)calculateOutput
{
    NSNumber *hot = self.hotInlet.value;
    NSMutableArray *cold = [self.coldInlet.value mutableCopy];
    
    if (cold && hot.integerValue >= 0 && hot.integerValue < cold.count) {
        self.mainOutlet.value = cold[hot.integerValue];
    }
}

@end
