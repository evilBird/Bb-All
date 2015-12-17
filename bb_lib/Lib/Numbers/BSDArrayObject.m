//
//  BSDArrayObject.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayObject.h"

@implementation BSDArrayObject

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initCold];
    inlet.name = @"cold inlet";
    return inlet;
}

@end
