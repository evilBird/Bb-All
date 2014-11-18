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

- (instancetype)initWithArguments:(id)arguments;

- (CALayer *)layer;
- (CALayer *)makeMyLayer;
- (CALayer *)makeMyLayerWithFrame:(CGRect)frame;
- (NSString *)displayName;
- (NSDictionary *)mapLayer:(CALayer *)layer;
- (NSDictionary *)propertiesForObject:(id)obj;

- (void)doAnimation;
- (void)doSelector;


@property (nonatomic,strong)BSDInlet *layerInlet;
@property (nonatomic,strong)BSDInlet *animationInlet;
@property (nonatomic,strong)BSDInlet *selectorInlet;
@property (nonatomic,strong)BSDInlet *setterInlet;
@property (nonatomic,strong)BSDInlet *getterInlet;
@property (nonatomic,strong)BSDOutlet *getterOutlet;

@end
