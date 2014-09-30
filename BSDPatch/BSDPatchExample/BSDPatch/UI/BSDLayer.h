//
//  BSDLayer.h
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import <QuartzCore/QuartzCore.h>

@interface BSDLayer : BSDObject

- (instancetype)initWithSuperView:(UIView *)superview;

- (CALayer *)layer;
- (CALayer *)superlayer;
- (NSString *)displayName;

@property (nonatomic,strong)BSDInlet *layerInlet;
@property (nonatomic,strong)BSDInlet *viewInlet;
@property (nonatomic,strong)BSDInlet *setterInlet;
@property (nonatomic,strong)BSDInlet *getterInlet;
@property (nonatomic,strong)BSDOutlet *getterOutlet;

@end
