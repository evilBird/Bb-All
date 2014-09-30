//
//  BSDLayer.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLayer.h"

@interface BSDLayer ()

@property (nonatomic,strong)NSMutableDictionary *setterDictionary;

@end

@implementation BSDLayer

- (instancetype)initWithSuperView:(UIView *)superview
{
    return [super initWithArguments:superview];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [self displayName];
    
    self.layerInlet = [[BSDInlet alloc]initHot];
    self.layerInlet.name = @"layer inlet";
    [self addPort:self.layerInlet];
    
    self.viewInlet = [[BSDInlet alloc]initHot];
    self.viewInlet.name = @"view inlet";
    [self addPort:self.viewInlet];
    
    self.setterInlet = [[BSDInlet alloc]initHot];
    self.setterInlet.name = @"setter inlet";
    [self addPort:self.setterInlet];
    
    self.getterInlet = [[BSDInlet alloc]initHot];
    self.getterInlet.name = @"getter inlet";
    [self addPort:self.getterInlet];
    
    self.getterOutlet = [[BSDOutlet alloc]init];
    self.getterOutlet.name = @"getter outlet";
    [self addPort:self.getterOutlet];
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.layerInlet || inlet == self.setterInlet) {
        [self updateLayer];
    }else if (inlet == self.getterInlet){
        CALayer *layer = [self layer];
        NSString *keyPath = inlet.value;
        [self.getterOutlet output:[layer valueForKeyPath:keyPath]];
    }else if (inlet == self.viewInlet){
        UIView *myView = inlet.value;
        if (myView && [myView isKindOfClass:[UIView class]]){
            CALayer *layer = [[CALayer alloc]init];
            layer.frame = myView.layer.frame;
            [myView.layer addSublayer:layer];
            [self.layerInlet input:layer];
        }
    }
}

- (void)updateLayer
{
    NSDictionary *setters = self.setterInlet.value;
    CALayer *myLayer = [self layer];
    
    if (setters && [setters isKindOfClass:[NSDictionary class]] && myLayer && [myLayer isKindOfClass:[CALayer class]]) {
        for (NSString *aKey in setters.allKeys) {
            id value = setters[aKey];
            if ([value isKindOfClass:[UIColor class]]) {
                UIColor *color = value;
                myLayer.backgroundColor = color.CGColor;
            }else{
                [myLayer setValue:setters[aKey] forKey:aKey];
            }
        }
        [myLayer setNeedsDisplay];
        [self.mainOutlet setValue:myLayer];
    }
}


- (NSString *)displayName
{
    return @"layer";
}

- (CALayer *)layer
{
    return self.layerInlet.value;
}

- (CALayer *)superlayer
{
    CALayer *myLayer = [self layer];
    return myLayer.superlayer;
}


@end
