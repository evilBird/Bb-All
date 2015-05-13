//
//  BSDStringObject.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDStringObject.h"

@implementation BSDStringObject

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDStringInlet alloc]initHot];
    inlet.name = @"hot";
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDStringInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

@end
