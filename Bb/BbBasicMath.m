//
//  BbTestObject.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBasicMath.h"
#import "BbTests.h"
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif
@implementation BbNumberObject

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    NSArray *types = @[@(BbValueType_Number)];
    return [NSSet setWithArray:types];
}

@end

@implementation BbNumberSlider

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.name = @"number";
}

+ (NSString *)UIType
{
    return @"hsl";
}

- (void)sliderValueDidChange:(id)sender
{
#if TARGET_OS_IPHONE == 1
    double value = [(UISlider *)sender value];
#else
    double value = [(NSSlider *)sender doubleValue];
#endif
    [self.hotInlet input:@(value)];
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        return hotValue;
    };
}

@end

@implementation BbAdd

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"+";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        double cold = [[inlets[1] getValue]doubleValue];
        return @(hot + cold);
    };
}

@end

@implementation BbSubtract

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"-";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        double cold = [[inlets[1] getValue]doubleValue];
        return @(hot - cold);
    };
}

@end

@implementation BbMultiply

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"*";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        double cold = [[inlets[1] getValue]doubleValue];
        return @(hot * cold);
    };
}


@end

@implementation BbDivide

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"/";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        double cold = [[inlets[1] getValue]doubleValue];
        return @(hot / cold);
    };
}

@end

@implementation BbMod

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"%";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSInteger hot = [hotValue integerValue];
        NSInteger cold = [[inlets[1] getValue]integerValue];
        return @(hot % cold);
    };
}

@end

@implementation BbPow

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"^";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        double cold = [[inlets[1] getValue]doubleValue];
        return @(pow(hot, cold));
    };
}

@end

@implementation BbSqrt

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.name = @"sqrt";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        return @(sqrt(hot));
    };
}
@end

@implementation BbRoot

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"root";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        double cold = [[inlets[1] getValue]doubleValue];
        return @(pow(hot, -cold));
    };
}

@end

@implementation BbLog10

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.name = @"log10";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        return @(log10(hot));
    };
}

@end

@implementation BbLog2

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.name = @"log2";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        return @(log2(hot));
    };
}

@end

@implementation BbLogNat

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.name = @"e^x";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        double hot = [hotValue doubleValue];
        return @(log(hot));
    };
}

@end
