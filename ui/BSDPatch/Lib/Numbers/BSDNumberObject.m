//
//  BSDNumberObject.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNumberObject.h"

@implementation BSDNumberObject

- (BSDInlet *)makeLeftInlet
{
    BSDNumberInlet *inlet = [[BSDNumberInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.delegate = self;
    
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDNumberInlet *inlet = [[BSDNumberInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

@end
