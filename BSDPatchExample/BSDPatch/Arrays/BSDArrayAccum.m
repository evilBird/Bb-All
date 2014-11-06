//
//  BSDArrayAccum.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayAccum.h"

@implementation BSDArrayAccum

- (instancetype)initWithMaxLength:(NSNumber *)maxLength
{
    return [super initWithArguments:maxLength];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"array accum";
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDInlet alloc]initHot];
    inlet.name = @"accum inlet";
    inlet.delegate = self;
    return inlet;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    BSDInlet *accum = [self inletNamed:@"accum inlet"];
    if (inlet == self.hotInlet) {
        if (!self.accumulated) {
            return;
        }
        [self.mainOutlet output:self.accumulated.mutableCopy];
    }else if (inlet == accum){
        [self.accumulated removeAllObjects];
        self.accumulated = nil;
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (value == nil) {
        return;
    }
    
    BSDInlet *accum = [self inletNamed:@"accum inlet"];
    if (inlet == accum) {
        
        if (!self.accumulated) {
            self.accumulated = [NSMutableArray array];
        }
        
        [self.accumulated addObject:value];
    }
}


- (void)calculateOutput
{
}

@end
