//
//  BSDLayerAnimation.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBasicAnimation.h"
#import "BSDCreate.h"

@interface BSDBasicAnimation ()

@property (nonatomic,strong)BSDRoute *route;
@property (nonatomic,strong)BSDArrayAccum *arrayAccum;
@property (nonatomic,strong)NSMutableDictionary *animationDictionary;
@property (nonatomic,strong)UIView *superview;

@end

@implementation BSDBasicAnimation
/*
- (instancetype)initWithLayer:(CALayer *)layer animation:(CABasicAnimation *)animation
{
    return [super initWithArguments:@{@"layer":layer,
                                      @"animation":animation,
                                      }];
}
 */

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"layer animation";
    
    NSDictionary *args = arguments;
    
    if (args && [args isKindOfClass:[NSDictionary class]]) {
        
        //self.coldInlet.value = args[@"layer"];
        self.animationDictionary = [[NSMutableDictionary alloc]init];
        CABasicAnimation *animation = args[@"animation"];
        self.animationDictionary[@"fromValue"] = animation.fromValue;
        self.animationDictionary[@"toValue"] = animation.toValue;
        self.animationDictionary[@"duration"] = @(animation.duration);
        self.animationDictionary[@"keyPath"] = animation.keyPath;
    }else if ([arguments isKindOfClass:[UIView class]]){
        self.superview = arguments;
    }
    
    self.viewInlet = [[BSDInlet alloc]initHot];
    self.viewInlet.name = @"view inlet";
    [self addPort:self.viewInlet];
    
    self.setterInlet = [[BSDInlet alloc]initHot];
    self.setterInlet.name = @"setter inlet";
    [self addPort:self.setterInlet];
    
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self doAnimation];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.viewInlet){
        //[self doAnimation];
    }else if (inlet == self.setterInlet){
        NSDictionary *dictionary = self.setterInlet.value;
        if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
            [self updateAnimationDictionaryWithDictionary:dictionary];
            //[self doAnimation];
        }
    }
}

- (void)updateAnimationDictionaryWithDictionary:(NSDictionary *)dictionary
{
    if (!self.animationDictionary) {
        self.animationDictionary = [NSMutableDictionary dictionary];
    }
    
    for (id key in dictionary.allKeys) {
        id value = [dictionary valueForKey:key];
        
        if (value != nil) {
            self.animationDictionary[key] = value;
        }
    }
}


- (void)calculateOutput

{
    /*
    NSDictionary *dictionary = self.animationDictionary;
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
        [self updateAnimationDictionaryWithDictionary: dictionary];

    }
    
    UIView *view = self.viewInlet.value;
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]] && view && [view isKindOfClass:[UIView class]]) {
        CALayer *layer = [self layer];
        CABasicAnimation *a = [self updateAnimation:dictionary];
        [layer addAnimation:a forKey:@"a"];
        [layer setValue:a.toValue forKey:a.keyPath];
        [self.animationDictionary setValue:a.toValue forKey:@"fromValue"];
    }
     */
}

- (void)doAnimation
{
    NSMutableDictionary *dictionary = [self.animationDictionary mutableCopy];
    UIView *view = self.viewInlet.value;
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]] && view && [view isKindOfClass:[UIView class]]) {
        CALayer *layer = view.layer;
        CABasicAnimation *a = [self getAnimation];
        [layer addAnimation:a forKey:@"a"];
        [layer setValue:a.toValue forKey:a.keyPath];
        [self.animationDictionary setValue:a.toValue forKey:@"toValue"];
    }
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (CALayer *)layer
{
    UIView *view = self.viewInlet.value;
    return view.layer;
}

- (CABasicAnimation *)getAnimation
{
    CABasicAnimation *animation = [[CABasicAnimation alloc]init];
    
    for (id aKey in self.animationDictionary) {
        [animation setValue:self.animationDictionary[aKey] forKey:aKey];
    }
    
    return animation;
}

@end
