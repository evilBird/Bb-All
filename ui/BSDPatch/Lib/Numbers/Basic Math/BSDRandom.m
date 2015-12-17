//
//  BSDRandom.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDRandom.h"

@implementation BSDRandom

- (instancetype)initWithMaxValue:(NSNumber *)maxValue
{
    return [super initWithArguments:maxValue];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"random";
    NSNumber *max = arguments;
    if (max && [max isKindOfClass:[NSNumber class]]) {
        self.coldInlet.value = max;
    }else{
        self.coldInlet.value = @(100);
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    int max = [self.coldInlet.value intValue];
    self.mainOutlet.value = @(arc4random_uniform(max));
}

@end
