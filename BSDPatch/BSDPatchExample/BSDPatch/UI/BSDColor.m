//
//  BSDColor.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDColor.h"
#import "BSDObjects.h"

@interface BSDColor ()

@property (nonatomic)CGFloat red;
@property (nonatomic)CGFloat blue;
@property (nonatomic)CGFloat green;
@property (nonatomic)CGFloat alpha;
@property (nonatomic)BSDRoute *route;
@property (nonatomic, strong)BSDValue *redValue;
@property (nonatomic, strong)BSDValue *blueValue;
@property (nonatomic, strong)BSDValue *greenValue;
@property (nonatomic, strong)BSDValue *alphaValue;

@end

@implementation BSDColor

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"color";
    BSDInlet *redInlet = [[BSDInlet alloc]initHot];
    redInlet.name = @"red";
    redInlet.delegate = self;
    [self addPort:redInlet];
    
    BSDInlet *greenInlet = [[BSDInlet alloc]initCold];
    greenInlet.name = @"green";
    [self addPort:greenInlet];
    
    BSDInlet *blueInlet = [[BSDInlet alloc]initCold];
    blueInlet.name = @"blue";
    [self addPort:blueInlet];
    
    BSDInlet *alphaInlet = [[BSDInlet alloc]initCold];
    alphaInlet.name = @"alpha";
    [self addPort:alphaInlet];
    
    NSArray *args = arguments;
    if (args && [args isKindOfClass:[NSArray class]] && args.count == 4) {
        redInlet.value = args[0];
        greenInlet.value = args[1];
        blueInlet.value = args[2];
        alphaInlet.value = args[3];
    }else{
        redInlet.value = @(1.);
        blueInlet.value = @(1.);
        greenInlet.value = @(1.);
        alphaInlet.value = @(1.);
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

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    BSDInlet *red = [self inletNamed:@"red"];
    if (inlet == red) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    UIColor *output = nil;
    output = [self currentColor];
    [self.mainOutlet output:output];
}

- (UIColor *)currentColor
{
    UIColor *color =[UIColor colorWithRed:[[(BSDInlet *)self.inlets[0] value] floatValue]
                                    green:[[(BSDInlet *)self.inlets[1] value] floatValue]
                                     blue:[[(BSDInlet *)self.inlets[2] value] floatValue]
                                      alpha:[[(BSDInlet *)self.inlets[3] value] floatValue]
                     ];
    

    return color;
}

@end
