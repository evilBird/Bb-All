//
//  BSDAffineTransform.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/26/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAffineTransform.h"
#import "NSValue+BSD.h"

@implementation BSDAffineTransform

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"transform 2d";
    self.a = [[BSDNumberInlet alloc]initHot];
    self.a.name = @"a";
    self.a.delegate = self;
    self.a.value = @(1);
    [self addPort:self.a];
    
    self.b = [[BSDNumberInlet alloc]initCold];
    self.b.name = @"b";
    self.b.value = @(0);
    [self addPort:self.b];
    
    self.c = [[BSDNumberInlet alloc]initCold];
    self.c.name = @"c";
    self.c.value = @(0);
    [self addPort:self.c];
    
    self.d = [[BSDNumberInlet alloc]initCold];
    self.d.name = @"d";
    self.c.value = @(1);
    [self addPort:self.d];
    
    self.tx = [[BSDNumberInlet alloc]initCold];
    self.tx.name = @"tx";
    self.tx.value = @(0);
    [self addPort:self.tx];
    
    self.ty = [[BSDNumberInlet alloc]initCold];
    self.ty.name = @"ty";
    self.ty.value = @(0);
    [self addPort:self.ty];
    
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    double a,b,c,d,tx,ty;
    a = [self.a.value doubleValue];
    b = [self.b.value doubleValue];
    c = [self.c.value doubleValue];
    d = [self.d.value doubleValue];
    tx = [self.tx.value doubleValue];
    ty = [self.ty.value doubleValue];
    
    CGAffineTransform transform = CGAffineTransformMake(a, b, c, d, tx, ty);
    NSValue *output = [NSValue valueWithCGAffineTransform:transform];
    [self.mainOutlet output:output];
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

@end
