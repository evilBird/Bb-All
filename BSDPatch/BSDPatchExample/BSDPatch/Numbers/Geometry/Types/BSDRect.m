//
//  BSDRect.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDRect.h"
#import "BSDCreate.h"

@implementation BSDRect

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"BSDRect";
    
    self.originXInlet = [[BSDInlet alloc]initHot];
    self.originXInlet.name = @"originX";
    self.originXInlet.delegate = self;
    self.originYInlet = [[BSDInlet alloc]initHot];
    self.originYInlet.name = @"originY";
    self.widthInlet = [[BSDInlet alloc]initHot];
    self.widthInlet.name = @"width";
    self.heightInlet = [[BSDInlet alloc]initHot];
    self.heightInlet.name = @"height";
    self.originXInlet.value = @(0);
    self.originYInlet.value = @(0);
    self.widthInlet.value = @(0);
    self.heightInlet.value = @(0);
    [self addPort:self.originXInlet];
    [self addPort:self.originYInlet];
    [self addPort:self.widthInlet];
    [self addPort:self.heightInlet];
    
    NSArray *initialRect = (NSArray *)arguments;
    
    if (initialRect && [initialRect isKindOfClass:[NSArray class]] && initialRect.count == 4) {
        self.originXInlet.value = initialRect[0];
        self.originYInlet.value = initialRect[1];
        self.widthInlet.value = initialRect[2];
        self.heightInlet.value = initialRect[3];
    }else{
        self.originXInlet.value = @(0);
        self.originYInlet.value = @(0);
        self.widthInlet.value = @(44);
        self.heightInlet.value = @(44);
    }

}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.originXInlet) {
        [self calculateOutput];
    }
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    NSNumber *x = self.originXInlet.value;
    NSNumber *y = self.originYInlet.value;
    NSNumber *w = self.widthInlet.value;
    NSNumber *h = self.heightInlet.value;
    
    if (x && y && w && h) {
        CGRect result;
        result.origin.x = x.doubleValue;
        result.origin.y = y.doubleValue;
        result.size.width = w.doubleValue;
        result.size.height = h.doubleValue;
        self.mainOutlet.value = [NSValue wrapRect:result];
    }
}

@end
