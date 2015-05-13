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

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"array element";
    NSNumber *index = arguments;
    if (index && [index isKindOfClass:[NSNumber class]]) {
        self.coldInlet.value = index;
    }
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.objectId = self.objectId;
    inlet.delegate = self;
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDNumberInlet alloc]initCold];
    inlet.name = @"cold";
    inlet.objectId = self.objectId;
    inlet.delegate = self;
    return inlet;
}

- (void)calculateOutput
{
    NSArray *hot = self.hotInlet.value;
    if (!hot || ![hot isKindOfClass:[NSArray class]]) {
        return;
    }
    NSNumber *cold = self.coldInlet.value;
    if (!cold || ![cold isKindOfClass:[NSNumber class]]) {
        return;
    }
    
    if (cold.integerValue > hot.count || cold.integerValue < 0) {
        return;
    }
    NSMutableArray *array = hot.mutableCopy;
    NSUInteger index = cold.integerValue;
    id output = [array objectAtIndex:index];
    
    [self.mainOutlet output:output];

}

@end
