//
//  BSDView.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDView.h"
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
    
    self.setterInlet = [[BSDInlet alloc]initHot];
    self.setterInlet.name = @"setter inlet";
    [self addPort:self.setterInlet];
    
    self.getterInlet = [[BSDInlet alloc]initHot];
    self.getterInlet.name = @"getter inlet";
    [self addPort:self.getterInlet];
    
    self.getterOutlet = [[BSDOutlet alloc]init];
    self.getterOutlet.name = @"getter outlet";
    [self addPort:self.getterOutlet];
    
    UIView *myView = [self view];
    [self.viewInlet setValue:myView];

    UIView *superview = (UIView *)arguments;
    if (superview) {
        myView.center = [myView convertPoint:superview.center toView:myView];
        [superview insertSubview:myView atIndex:0];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.viewInlet) {
        [self.mainOutlet output:[self mapView:[self view]]];
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
        NSMutableDictionary *output = [@{@"view":myView,
                                         @"layer":myView.layer,
                                         @"superview":myView.superview,
                                         @"map":@{@"view":[self mapView:myView],
                                                  @"superview":[self mapView:myView.superview]
                                                  }
                                         }mutableCopy];
        
        [self.mainOutlet output:output];
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
