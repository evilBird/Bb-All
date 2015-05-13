//
//  BSDControl.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDControl.h"

@interface BSDControl ()
{
    id myControl;
}

@end

@implementation BSDControl

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    
    self.eventOutlet = [[BSDOutlet alloc]init];
    self.eventOutlet.name = @"event outlet";
    [self addPort:self.eventOutlet];
    
    self.name = @"control";
    
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.viewInlet) {
        if (!myControl || myControl != self.viewInlet.value) {
            myControl = self.viewInlet.value;
            [myControl addTarget:self action:@selector(handleControlActionBegan:) forControlEvents:UIControlEventEditingDidBegin];
            [myControl addTarget:self action:@selector(handleControlActionChanged:) forControlEvents:UIControlEventEditingChanged];
            [myControl addTarget:self action:@selector(handleControlActionEnded:) forControlEvents:UIControlEventEditingDidEnd];
            [myControl addTarget:self action:@selector(handleControlActionBegan:)forControlEvents:UIControlEventTouchDown];
            [myControl addTarget:self action:@selector(handleControlActionChanged:)forControlEvents:UIControlEventValueChanged];
            [myControl addTarget:self action:@selector(handleControlActionEnded:)forControlEvents:UIControlEventTouchUpInside];

            //[myControl addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventAllEvents];

        }
    }
    
    [super hotInlet:inlet receivedValue:value];
}

- (UIView *)makeMyViewWithFrame:(CGRect)frame
{
    return nil;
}

- (void)handleAction:(id)sender
{
    [self.eventOutlet output:sender];
}

- (void)handleControlActionBegan:(id)sender
{
    [self.eventOutlet output:@[@(1),sender]];
}

- (void)handleControlActionChanged:(id)sender
{
    [self.eventOutlet output:@[@(2),sender]];
}

- (void)handleControlActionEnded:(id)sender
{
    [self.eventOutlet output:@[@(3),sender]];
}

@end
