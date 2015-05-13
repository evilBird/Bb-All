//
//  BSDLayerAnimation.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBasicAnimation.h"
#import "BSDCreate.h"
#import "BSDStringInlet.h"
#import "BSDNumberInlet.h"
#import "BSDDictionaryInlet.h"
#import "NSValue+BSD.h"

@interface BSDBasicAnimation ()

@end

@implementation BSDBasicAnimation

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"basic animation";
    
    self.keyPathInlet = [[BSDStringInlet alloc]initCold];
    self.keyPathInlet.name = @"keyPath";
    self.keyPathInlet.value = @"position";
    [self addPort:self.keyPathInlet];
    
    self.fromValueInlet =[[BSDInlet alloc]initCold];
    self.fromValueInlet.name = @"fromValue";
    self.fromValueInlet.value = [NSValue wrapPoint:CGPointMake(0, 0)];
    [self addPort:self.fromValueInlet];
    
    self.toValueInlet = [[BSDInlet alloc]initCold];
    self.toValueInlet.name = @"toValue";
    self.toValueInlet.value = [NSValue wrapPoint:CGPointMake(0, 0)];
    [self addPort:self.toValueInlet];
    
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
    CABasicAnimation *animation = [self getAnimation];
    if (animation) {
        [self.mainOutlet output:animation];
    }
}

- (CABasicAnimation *)getAnimation
{
    CABasicAnimation *animation = [[CABasicAnimation alloc]init];
    animation.keyPath = self.keyPathInlet.value;
    animation.fromValue = self.fromValueInlet.value;
    animation.toValue = self.toValueInlet.value;
    animation.duration = [self.durationInlet.value doubleValue];
    
    return animation;
}

@end
