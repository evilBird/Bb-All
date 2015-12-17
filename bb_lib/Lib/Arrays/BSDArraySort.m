//
//  BSDArraySort.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArraySort.h"

@implementation BSDArraySort

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"sort array";
    NSArray *sortDescriptors = arguments;
    if (sortDescriptors && [sortDescriptors isKindOfClass:[NSArray class]]) {
        self.coldInlet.value = sortDescriptors.mutableCopy;
    }
}

- (void)calculateOutput
{
    NSArray *hot = self.hotInlet.value;
    NSArray *cold = self.coldInlet.value;
    if (!hot || !cold || ![hot isKindOfClass:[NSArray class]] || ![cold isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableArray *toSort = hot.mutableCopy;
    NSMutableArray *sortDescriptors = cold.mutableCopy;
    NSArray *output = [toSort sortedArrayUsingDescriptors:sortDescriptors];
    [self.mainOutlet output:output];
}


@end
