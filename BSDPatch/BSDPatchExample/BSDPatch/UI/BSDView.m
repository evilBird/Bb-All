//
//  BSDView.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDView.h"

@implementation BSDView

- (instancetype)initWithUIView:(UIView *)view
{
    return [super initWithArguments:view];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"view";
    
    self.getterInlet = [[BSDInlet alloc]init];
    self.getterInlet.name = @"getter inlet";
    self.getterInlet.hot = YES;
    [self addPort:self.getterInlet];
    
    self.getterOutlet = [[BSDOutlet alloc]init];
    self.getterOutlet.name = @"getter outlet";
    [self addPort:self.getterOutlet];
    
    
    UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    myView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
    [self.coldInlet setValue:myView];

    UIView *superview = (UIView *)arguments;
    if (superview) {
        myView.center = [myView convertPoint:superview.center toView:myView];
        [superview insertSubview:myView atIndex:0];
    }
}

- (void)setSuperView:(UIView *)superview
{
    if (superview) {
        UIView *myView = self.coldInlet.value;
        myView.center = [myView convertPoint:superview.center toView:myView];
        [superview addSubview:myView];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self hotInlet:self.hotInlet receivedValue:self.hotInlet.value];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }else if (inlet == self.getterInlet){
        UIView *view = [self view];
        NSString *keyPath = inlet.value;
        self.getterOutlet.value = [view valueForKeyPath:keyPath];
    }
}

- (void)calculateOutput
{
    NSDictionary *hot = self.hotInlet.value;
    UIView *cold = self.coldInlet.value;
    
    if (hot && cold) {
        for (NSString *aKey in hot.allKeys) {
            [cold setValue:hot[aKey] forKey:aKey];
        }
        [cold setNeedsDisplay];
        [self.mainOutlet setValue:self.coldInlet.value];
    }
}

- (UIView *)view
{
    return self.coldInlet.value;
}




@end
