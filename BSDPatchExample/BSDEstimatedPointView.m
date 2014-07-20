//
//  BSDEstimatedPointView.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDEstimatedPointView.h"

@implementation BSDEstimatedPointView

- (instancetype)initWithUIView:(UIView *)view
{
    return [super initWithArguments:view];
}

- (void)setupWithArguments:(id)arguments
{
    self.center = [[BSDInlet alloc]initHot];
    self.center.name = @"center";
    self.alpha = [[BSDInlet alloc]initHot];
    self.alpha.name = @"alpha";
    
    UIView *view = (UIView *)arguments;
    if (view) {
        //set up distance measurement objects & helper
        self.mainView = [BSDCreate viewWithUIView:view];
        
    }
    
    self.prependCenter = [BSDCreate prependKeyCold:@"center"];
    self.prependAlpha = [BSDCreate prependKeyCold:@"alpha"];
    
    [self.alpha forwardToPort:self.prependAlpha.hotInlet];
    [self.center forwardToPort:self.prependCenter.hotInlet];
    
    [self.prependAlpha connect:self.mainView.hotInlet];
    [self.prependCenter connect:self.mainView.hotInlet];
    
}

- (UIView *)view
{
    return self.mainView.coldInlet.value;
}

@end
