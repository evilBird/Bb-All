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
    BSDNumberInlet *redInlet = [[BSDNumberInlet alloc]initHot];
    redInlet.name = @"red";
    redInlet.delegate = self;
    [self addPort:redInlet];
    
    BSDNumberInlet *greenInlet = [[BSDNumberInlet alloc]initHot];
    greenInlet.name = @"green";
    [self addPort:greenInlet];
    
    BSDNumberInlet *blueInlet = [[BSDNumberInlet alloc]initHot];
    blueInlet.name = @"blue";
    [self addPort:blueInlet];
    
    BSDNumberInlet *alphaInlet = [[BSDNumberInlet alloc]initHot];
    alphaInlet.name = @"alpha";
    [self addPort:alphaInlet];
    
    //[self.coldInlet setHot:YES];
    //self.coldInlet.delegate = self;
    /*
    self.redValue = [[BSDValue alloc]initWithValue:@(0)];
    self.blueValue = [[BSDValue alloc]initWithValue:@(0)];
    self.greenValue = [[BSDValue alloc]initWithValue:@(0)];
    self.alphaValue = [[BSDValue alloc]initWithValue:@(1)];
    //self.route = [[BSDRoute alloc]initWithRouteKeys:@[@"red",@"blue",@"green",@"alpha"]];
    [[self.route outletForRouteKey:@"red"]connectToInlet:self.redValue.coldInlet];
    [[self.route outletForRouteKey:@"blue"]connectToInlet:self.blueValue.coldInlet];
    [[self.route outletForRouteKey:@"green"]connectToInlet:self.greenValue.coldInlet];
    [[self.route outletForRouteKey:@"alpha"]connectToInlet:self.alphaValue.coldInlet];
    [self.coldInlet forwardToPort:self.route.hotInlet];
    
    
    NSArray *args = arguments;
    
    if ([args isKindOfClass:[NSArray class]] && args.count == 4) {
     
        [self.redValue.coldInlet input:args[0]];
        [self.blueValue.coldInlet input:args[1]];
        [self.greenValue.coldInlet input:args[2]];
        [self.alphaValue.coldInlet input:args[3]];
        
    }
     */
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

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    [self calculateOutput];
}

- (void)calculateOutput
{
    self.mainOutlet.value = [self currentColor];
}

- (UIColor *)currentColor
{
    double r = [[[self inletNamed:@"red"]value]doubleValue];
    double g = [[[self inletNamed:@"green"]value]doubleValue];
    double b = [[[self inletNamed:@"blue"]value]doubleValue];
    double a = [[[self inletNamed:@"alpha"]value]doubleValue];
    return [UIColor colorWithRed:r
                           green:g
                            blue:b
                           alpha:a];
}

@end
