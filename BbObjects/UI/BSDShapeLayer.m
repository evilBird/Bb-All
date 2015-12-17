//
//  BSDShapeLayer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDShapeLayer.h"

@implementation BSDShapeLayer

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"shape layer";
}

- (CALayer *)makeMyLayerWithFrame:(CGRect)frame
{
    CAShapeLayer *myLayer = [[CAShapeLayer alloc]init];
    myLayer.frame = frame;
    return myLayer;
}

@end
