//
//  BSDView.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDView.h"
#import "BSDStringInlet.h"
#import <objc/runtime.h>

@implementation BSDView

- (instancetype)initWithSuperView:(UIView *)superview
{
    return [super initWithArguments:superview];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [self displayName];
    
    self.viewInlet = [[BSDInlet alloc]initHot];
    self.viewInlet.name = @"view inlet";
    self.viewInlet.delegate = self;
    [self addPort:self.viewInlet];
    
    self.animationInlet = [[BSDInlet alloc]initHot];
    self.animationInlet.name = @"animation inlet";
    [self addPort:self.animationInlet];
    
    self.viewSelectorInlet = [[BSDInlet alloc]initHot];
    self.viewSelectorInlet.name = @"view selector inlet";
    [self addPort:self.viewSelectorInlet];
    
    self.setterInlet = [[BSDInlet alloc]initHot];
    self.setterInlet.name = @"setter inlet";
    [self addPort:self.setterInlet];
    
    self.getterInlet = [[BSDInlet alloc]initHot];
    self.getterInlet.name = @"getter inlet";
    self.getterInlet.delegate = self;
    [self addPort:self.getterInlet];
    
    self.getterOutlet = [[BSDOutlet alloc]init];
    self.getterOutlet.name = @"getter outlet";
    [self addPort:self.getterOutlet];
    
    UIView *superview = (UIView *)arguments;
    self.viewInlet.value = superview;
    if (superview && [superview isKindOfClass:[UIView class]]) {
        self.viewInlet.value = superview;
    }else{
        UIView *myView = [self view];
        [self.viewInlet setValue:myView];
    }

}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.viewInlet) {
        [self.mainOutlet output:self.viewInlet.value];
    }else if (inlet == self.getterInlet){
        [self.getterOutlet output:[self mapView:self.viewInlet.value]];
    }
}

- (NSString *)displayName
{
    return @"view";
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)setSuperView:(UIView *)superview
{
    if (superview) {
        UIView *myView = self.viewInlet.value;
        myView.center = [myView convertPoint:superview.center toView:myView];
        if (myView.superview!=nil) {
            [myView removeFromSuperview];
        }
        
        [superview addSubview:myView];
    }
}

- (UIView *)superview
{
    UIView *myView = self.viewInlet.value;
    return myView.superview;
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.viewInlet) {
        [self updateView];
    }else if (inlet == self.getterInlet){
        UIView *view = [self view];
        NSString *keyPath = inlet.value;
        [self.getterOutlet output:[view valueForKeyPath:keyPath]];
    }else if (inlet == self.setterInlet){
        [self updateView];
    }else if (inlet == self.viewSelectorInlet){
        [self doSelector];
    }else if (inlet == self.animationInlet){
        [self doAnimation];
    }
}

- (void)doAnimation
{
    id a = self.animationInlet.value;
        if (a == nil) {
        return;
    }
    
    if ([a isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *animation = self.animationInlet.value;
        UIView *myView = [self view];
        CALayer *layer = myView.layer;
        [layer addAnimation:animation forKey:@"a"];
        [layer setValue:animation.toValue forKey:animation.keyPath];
    }else if ([a isKindOfClass:[CAKeyframeAnimation class]]){
        CAKeyframeAnimation *animation = self.animationInlet.value;
        UIView *myView = [self view];
        CALayer *layer = myView.layer;
        [layer addAnimation:animation forKey:@"a"];
        [layer setValue:animation.values.lastObject forKey:animation.keyPath];
    }
}

- (void)doSelector
{
    id val = self.viewSelectorInlet.value;
    
    if (val == nil) {
        return;
    }
    
    if (!([val isKindOfClass:[NSDictionary class]]||[val isKindOfClass:[NSString class]])) {
        return;
    }
    
    NSString *selectorName = nil;
    id arg = nil;
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        selectorName = [val allKeys].firstObject;
        arg = [val allValues].firstObject;
    }else if ([val isKindOfClass:[NSString class]]){
        selectorName = val;
    }
    
    if (!selectorName || selectorName.length == 0) {
        return;
    }
    
    SEL selector = NSSelectorFromString(selectorName);
    UIView *myView = [self view];
    Class c = [myView class];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:selector]];
    invocation.target = myView;
    invocation.selector = selector;
    
    if (arg != nil) {
        [invocation setArgument:&arg atIndex:2];
    }
    
    if ([myView respondsToSelector:selector]) {
        [invocation invoke];
    }
}

- (void)updateView
{
    NSDictionary *setters = self.setterInlet.value;
    UIView *myView = [self view];
    
    if (setters && [setters isKindOfClass:[NSDictionary class]] && myView && [myView isKindOfClass:[UIView class]]) {
        for (NSString *aKey in setters.allKeys) {
            [myView setValue:setters[aKey] forKey:aKey];
        }
        [myView setNeedsDisplay];
        /*
        NSMutableDictionary *output = [@{@"view":myView,
                                         @"layer":myView.layer,
                                         @"superview":myView.superview,
                                         @"map":@{@"view":[self mapView:myView],
                                                  @"superview":[self mapView:myView.superview]
                                                  }
                                         }mutableCopy];
         */
        
        [self.mainOutlet output:self.viewInlet.value];
    }
}

- (UIView *)view
{
    UIView *myView = self.viewInlet.value;
    if (!myView) {
        myView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        myView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1];
        self.viewInlet.value = myView;
    }
    
    return myView;
}

- (NSArray *)properties:(id)obj
{
    NSMutableArray *result = nil;
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (!result) {
            result = [NSMutableArray array];
        }
        [result addObject:key];
    }
    
    return result;
}

- (NSDictionary *)mapView:(UIView *)view
{
    NSArray *properties = [self properties:view];
    return [view dictionaryWithValuesForKeys:properties];
}


@end
