//
//  BSDDelay.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/23/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDelay.h"

@implementation BSDDelay

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"del";
    NSNumber *number = arguments;
    if (number && [number isKindOfClass:[NSNumber class]]) {
        self.coldInlet.value = number;
    }else{
        self.coldInlet.value = @(1);
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        NSNumber *interval = self.coldInlet.value;
        BSDBang *bang = [BSDBang bang];
        if (interval && [interval isKindOfClass:[NSNumber class]]) {
            NSTimeInterval time = interval.doubleValue;
            __weak BSDDelay *weakself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself sendOutput:bang];
            });
            
        }
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    NSNumber *interval = self.coldInlet.value;
    if (hot != nil && interval && [interval isKindOfClass:[NSNumber class]]) {
        NSTimeInterval time = interval.doubleValue;
        __weak BSDDelay *weakself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself sendOutput:hot];
        });
    }
}

- (void)sendOutput:(id)output
{
    [self.mainOutlet output:output];
}

@end
