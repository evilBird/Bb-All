//
//  BSDLayerAnimation.h
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDBasicAnimation : BSDObject

@property (nonatomic,strong)BSDInlet *keyPathInlet;
@property (nonatomic,strong)BSDInlet *fromValueInlet;
@property (nonatomic,strong)BSDInlet *toValueInlet;
@property (nonatomic,strong)BSDInlet *durationInlet;


@end
