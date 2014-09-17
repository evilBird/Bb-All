//
//  BSDLabel.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLabel.h"

@implementation BSDLabel

- (instancetype)initWithSuperview:(UIView *)superview
{
    return [super initWithArguments:superview];
}
/*
- (instancetype)initWithUILabel:(UILabel *)label
{
    return [super initWithArguments:label];
}
 */

- (void)setupWithArguments:(id)arguments
{
    self.name = @"label";
    
    self.getterInlet = [[BSDInlet alloc]init];
    self.getterInlet.name = @"getter inlet";
    self.getterInlet.hot = YES;
    [self addPort:self.getterInlet];
    
    self.getterOutlet = [[BSDOutlet alloc]init];
    self.getterOutlet.name = @"getter outlet";
    [self addPort:self.getterOutlet];
    
    //UILabel *label = (UILabel *)arguments;
    CGRect frame = CGRectMake(0, 0, 88,44);
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.coldInlet.value = label;
    label.text = @"BSDLabel";
    [label sizeToFit];
    UIView *superview = arguments;
    if (superview) {
        label.center = [label convertPoint:superview.center toView:label];
        [superview insertSubview:label atIndex:0];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }else if (inlet == self.getterInlet){
        UIView *view = [self label];
        NSString *keyPath = inlet.value;
        self.getterOutlet.value = [view valueForKeyPath:keyPath];
    }
}

- (void)calculateOutput
{
    
    NSDictionary *hot = self.hotInlet.value;
    if ([hot isKindOfClass:[BSDBang class]]) {
        [self.mainOutlet setValue:self.coldInlet.value];
    }else{
     
        UIView *cold = self.coldInlet.value;
        if (hot && cold) {
            for (NSString *aKey in hot.allKeys) {
                [cold setValue:hot[aKey] forKey:aKey];
            }
            
            self.mainOutlet.value = self.coldInlet.value;
        }
    }
}

- (UILabel *)label
{
    return self.coldInlet.value;
}

@end
