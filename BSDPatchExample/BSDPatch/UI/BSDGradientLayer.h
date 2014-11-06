//
//  BSDGradientLayer.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import <QuartzCore/QuartzCore.h>

@interface BSDGradientLayer : BSDObject

@property (nonatomic,strong)BSDInlet *startPointInlet;
@property (nonatomic,strong)BSDInlet *endPointInlet;
@property (nonatomic,strong)BSDInlet *startColorInlet;
@property (nonatomic,strong)BSDInlet *endColorInlet;

@end
