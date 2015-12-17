//
//  BSDDictionaryObject.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDictionaryObject.h"

@implementation BSDDictionaryObject

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDDictionaryInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDDictionaryInlet alloc]initHot];
    inlet.name = @"hot";
    return inlet;
}

@end
