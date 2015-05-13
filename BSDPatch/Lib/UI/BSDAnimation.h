//
//  BSDAnimation.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDAnimation : BSDObject

@property (nonatomic,strong)BSDInlet *keyPathInlet;
@property (nonatomic,strong)BSDInlet *valuesInlet;
@property (nonatomic,strong)BSDInlet *durationInlet;

@end
