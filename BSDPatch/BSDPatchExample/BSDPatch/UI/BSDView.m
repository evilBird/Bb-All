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

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
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
    self.animationInlet.delegate = self;
    [self addPort:self.animationInlet];
    
    self.viewSelectorInlet = [[BSDInlet alloc]initHot];
    self.viewSelectorInlet.name = @"view selector inlet";
    self.viewSelectorInlet.delegate = self;
    [self addPort:self.viewSelectorInlet];
    
    self.setterInlet = [[BSDInlet alloc]initHot];
    self.setterInlet.name = @"setter inlet";
    self.setterInlet.delegate = self;
    [self addPort:self.setterInlet];
    
    self.getterInlet = [[BSDInlet alloc]initHot];
    self.getterInlet.name = @"getter inlet";
    self.getterInlet.delegate = self;
    [self addPort:self.getterInlet];
    
    self.getterOutlet = [[BSDOutlet alloc]init];
    self.getterOutlet.name = @"getter outlet";
    [self addPort:self.getterOutlet];
    
    NSArray *frameArr = arguments;
    CGRect frame = CGRectMake(0, 0, 44, 44);
    if (frameArr && [frameArr isKindOfClass:[NSArray class]] && frameArr.count == 4) {
        frame.origin.x = [arguments[0] doubleValue];
        frame.origin.y = [arguments[1] doubleValue];
        frame.size.width = [arguments[2] doubleValue];
        frame.size.height = [arguments[3] doubleValue];
        UIView *myView = [self makeMyViewWithFrame:frame];
        self.viewInlet.value = myView;
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.viewInlet) {
        UIView *myView = [self view];
        
        if (myView == nil) {
            myView = [self makeMyView];
            self.viewInlet.value = myView;
        }
        
        [self.mainOutlet output:self.viewInlet.value];
    }else if (inlet == self.getterInlet){
        //[self.getterOutlet output:[self mapView:self.viewInlet.value]];
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

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.viewInlet) {
        [self updateView];
        [self.mainOutlet output:[self view]];
    }else if (inlet == self.setterInlet){
        [self updateView];
    }else if (inlet == self.viewSelectorInlet){
        [self doSelector];
    }else if (inlet == self.animationInlet){
        [self doAnimation];
    }else if (inlet == self.getterInlet){
        [self getValue];
    }
}

- (void)getValue
{
    NSString *getter = self.getterInlet.value;
    if (!getter || ![getter isKindOfClass:[NSString class]]) {
        return;
    }
    UIView *view = self.viewInlet.value;
    if (!view) {
        return;
    }
    
    NSString *keyPath = [NSString stringWithString:getter];
    id value = [view valueForKeyPath:keyPath];
    NSDictionary *output = @{keyPath:value};
    [self.getterOutlet output:output];
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
        [layer addAnimation:animation forKey:animation.keyPath];
        [layer setValue:animation.toValue forKey:animation.keyPath];
    }else if ([a isKindOfClass:[CAKeyframeAnimation class]]){
        CAKeyframeAnimation *animation = self.animationInlet.value;
        UIView *myView = self.viewInlet.value;
        [myView.layer addAnimation:animation forKey:animation.keyPath];
        [myView.layer setValue:animation.values.lastObject forKey:animation.keyPath];
    }
}

- (void)doSelectorWithArray:(NSArray *)array
{
    if (!array || array.count == 0) {
        return;
    }
    
    NSMutableArray *copy = array.mutableCopy;
    id first = copy.firstObject;
    if (![first isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSString *selectorName = [NSString stringWithString:first];
    NSArray *args = nil;
    if (copy.count > 1) {
        [copy removeObject:first];
        args = [NSArray arrayWithArray:copy];
    }
    
    SEL selector = NSSelectorFromString(selectorName);
    UIView *myView = [self view];
    
    if (!myView) {
        return;
    }
    
    Class c = [myView class];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:selector]];
    invocation.target = myView;
    invocation.selector = selector;
    
    if (args != nil) {
        for (NSUInteger idx = 0; idx < args.count; idx ++) {
            NSInteger argIdx = 2+idx;
            id myArg = args[idx];
            [invocation setArgument:&myArg atIndex:argIdx];
        }
    }
    
    if ([myView respondsToSelector:selector]) {
        [invocation invoke];
    }
    
    
}

- (void)doSelector
{
    id val = self.viewSelectorInlet.value;
    
    if (val == nil) {
        return;
    }
    
    if ([val isKindOfClass:[NSArray class]]) {
        [self doSelectorWithArray:val];
        return;
    }
    
    if ([val isKindOfClass:[NSString class]]) {
        NSArray *arr = @[val];
        [self doSelectorWithArray:arr];
        return;
    }
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = val;
        NSArray *arr = @[dict.allKeys.firstObject,dict.allValues.firstObject];
        [self doSelectorWithArray:arr];
        return;
    }

}

- (void)updateView
{
    NSDictionary *setters = self.setterInlet.value;
    UIView *myView = self.view;
    
    if (setters && [setters isKindOfClass:[NSDictionary class]] && myView && [myView isKindOfClass:[UIView class]]) {
        for (NSString *aKey in setters.allKeys) {
            [myView setValue:setters[aKey] forKey:aKey];
        }
        [myView setNeedsDisplay];
        [self.mainOutlet output:self.viewInlet.value];
    }
}

- (UIView *)view
{
    UIView *myView = self.viewInlet.value;
    return myView;
     
}

- (UIView *)makeMyView
{
    return [self makeMyViewWithFrame:CGRectMake(0, 0, 44, 44)];
}

- (UIView *)makeMyViewWithFrame:(CGRect)frame
{
    UIView *myView = [[UIView alloc]initWithFrame:frame];
    myView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1];
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
