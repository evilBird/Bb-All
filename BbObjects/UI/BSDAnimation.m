//
//  BSDAnimation.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAnimation.h"
#import "BSDStringInlet.h"
#import "BSDNumberInlet.h"


@implementation BSDAnimation

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"animation";
    
    self.keyPathInlet = [[BSDStringInlet alloc]initCold];
    self.keyPathInlet.name = @"keyPath";
    self.keyPathInlet.value = @"position";
    [self addPort:self.keyPathInlet];
    
    self.valuesInlet = [[BSDInlet alloc]initCold];
    self.valuesInlet.name = @"values";
    self.valuesInlet.value = nil;
    [self addPort:self.valuesInlet];
    
    self.durationInlet = [[BSDNumberInlet alloc]initCold];
    self.durationInlet.name = @"duration";
    self.durationInlet.value = @(1);
    [self addPort:self.durationInlet];
    
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
    CAKeyframeAnimation *animation = [self getAnimation];
    if (animation) {
        [self.mainOutlet output:animation];
    }
}

- (CAKeyframeAnimation *)getAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    NSString *keyPath = self.keyPathInlet.value;
    if (!keyPath) {
        return nil;
    }
    animation.keyPath = keyPath;
    NSMutableArray *values = nil;
    id vals = self.valuesInlet.value;
    
    if (vals == nil) {
        return nil;
    }
    
    if ([vals isKindOfClass:[NSArray class]]) {
        values = [vals mutableCopy];
    }else{
        values = [NSMutableArray arrayWithObject:vals];
    }
    
    animation.values = values;
    
    NSNumber *duration = self.durationInlet.value;
    
    if (!duration) {
        return nil;
    }
    
    animation.duration = duration.doubleValue;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:animation.values.count];
    for (NSUInteger i = 0; i < animation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    }
    [animation setTimingFunctions:timingFunctions.copy];
    animation.removedOnCompletion = NO;
    return animation;
}

@end
