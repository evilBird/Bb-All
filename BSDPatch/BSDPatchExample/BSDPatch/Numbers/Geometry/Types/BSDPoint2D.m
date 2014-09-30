//
//  BSDPoint.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPoint2D.h"
#import "BSDCreate.h"

@implementation BSDPoint2D

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"2d point";
    self.xInlet = [[BSDInlet alloc]initHot];
    self.xInlet.name = @"x";
    self.xInlet.value = @0;
    self.yInlet = [[BSDInlet alloc]initHot];
    self.yInlet.name = @"y";
    self.yInlet.value = @0;
    [self addPort:self.xInlet];
    [self addPort:self.yInlet];
    
    NSArray *initVal = (NSArray *)arguments;
    if (initVal && [initVal isKindOfClass:[NSArray class]] && initVal.count == 2) {
        self.xInlet.value = initVal[0];
        self.yInlet.value = initVal[1];
    }
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSNumber *x = self.xInlet.value;
    NSNumber *y = self.yInlet.value;
    if (x && y) {
        CGPoint output;
        output.x = x.doubleValue;
        output.y = y.doubleValue;
        
        self.mainOutlet.value = [NSValue wrapPoint:output];
    }
}

@end
