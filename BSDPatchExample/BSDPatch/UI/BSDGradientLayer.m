//
//  BSDGradientLayer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGradientLayer.h"
#import "NSValue+BSD.h"

@implementation BSDGradientLayer

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"gradient";
    self.startPointInlet = [[BSDInlet alloc]initHot];
    self.startPointInlet.name = @"start point";
    self.startPointInlet.value = [NSValue wrapPoint:CGPointMake(0, 0)];
    [self addPort:self.startPointInlet];
    
    self.endPointInlet = [[BSDInlet alloc]initHot];
    self.endPointInlet.name = @"end point";
    self.endPointInlet.value = [NSValue wrapPoint:CGPointMake(0, 100)];
    [self addPort:self.endPointInlet];
    
    self.startColorInlet = [[BSDInlet alloc]initHot];
    self.startColorInlet.name = @"start color";
    self.startColorInlet.value = [UIColor whiteColor];
    [self addPort:self.startColorInlet];
    
    self.endColorInlet = [[BSDInlet alloc]initHot];
    self.endColorInlet.name = @"end color";
    self.endPointInlet.value = [UIColor clearColor];
    [self addPort:self.endColorInlet];
    
    CALayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, 44, 44);
    self.hotInlet.value = layer;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    CAGradientLayer *layer = self.hotInlet.value;
    NSValue *start = self.startPointInlet.value;
    NSValue *end = self.endPointInlet.value;
    CGPoint startPt = start.CGPointValue;
    CGPoint endPt = end.CGPointValue;
    UIColor *startCol = self.startColorInlet.value;
    UIColor *endCol = self.endColorInlet.value;
    
}

@end
