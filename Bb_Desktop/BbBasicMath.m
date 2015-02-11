//
//  BbTestObject.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBasicMath.h"
#import "BbTests.h"


@implementation BbNumberObject

- (NSArray *)allowedTypesForPort:(BbPort *)port
{
    return @[NSStringFromClass([@(0) class])];
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

- (NSArray *)testCases
{
    NSMutableArray *testCases = [NSMutableArray array];
    BbTestCase *testCase1 = [[BbTestCase alloc]initWithName:self.className];
    [testCase1 setInputValue:@(10.) forInletAtIndex:0];
    [testCase1 setInputValue:@(0.5) forInletAtIndex:1];
    testCase1.expectedOutput = @(10.5);
    testCase1.caseNumber = 1;
    [testCases addObject:testCase1];
    
    BbTestCase *testCase2 = [[BbTestCase alloc]initWithName:self.className];
    [testCase2 setInputValue:@(1) forInletAtIndex:0];
    [testCase2 setInputValue:@(5) forInletAtIndex:1];
    testCase2.expectedOutput = @(6);
    testCase2.caseNumber = 2;
    [testCases addObject:testCase2];
    return testCases;
    return nil;
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

- (NSArray *)testCases
{
    NSMutableArray *testCases = [NSMutableArray array];
    BbTestCase *testCase1 = [[BbTestCase alloc]initWithName:self.className];
    [testCase1 setInputValue:@(10.) forInletAtIndex:0];
    [testCase1 setInputValue:@(0.5) forInletAtIndex:1];
    testCase1.expectedOutput = @(9.5);
    testCase1.caseNumber = 1;
    [testCases addObject:testCase1];
    
    BbTestCase *testCase2 = [[BbTestCase alloc]initWithName:self.className];
    [testCase2 setInputValue:@(1) forInletAtIndex:0];
    [testCase2 setInputValue:@(5) forInletAtIndex:1];
    testCase2.expectedOutput = @(-4);
    testCase2.caseNumber = 2;
    [testCases addObject:testCase2];
    return testCases;
    return nil;
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

- (NSArray *)testCases
{
    NSMutableArray *testCases = [NSMutableArray array];
    BbTestCase *testCase1 = [[BbTestCase alloc]initWithName:self.className];
    [testCase1 setInputValue:@(10.) forInletAtIndex:0];
    [testCase1 setInputValue:@(0.5) forInletAtIndex:1];
    testCase1.expectedOutput = @(5);
    testCase1.caseNumber = 1;
    [testCases addObject:testCase1];
    
    BbTestCase *testCase2 = [[BbTestCase alloc]initWithName:self.className];
    [testCase2 setInputValue:@(-1) forInletAtIndex:0];
    [testCase2 setInputValue:@(5) forInletAtIndex:1];
    testCase2.expectedOutput = @(-5);
    testCase2.caseNumber = 2;
    [testCases addObject:testCase2];
    return testCases;
    return nil;
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

- (NSArray *)testCases
{
    NSMutableArray *testCases = [NSMutableArray array];
    BbTestCase *testCase1 = [[BbTestCase alloc]initWithName:self.className];
    [testCase1 setInputValue:@(10.) forInletAtIndex:0];
    [testCase1 setInputValue:@(0.5) forInletAtIndex:1];
    testCase1.expectedOutput = @(20);
    testCase1.caseNumber = 1;
    [testCases addObject:testCase1];
    
    BbTestCase *testCase2 = [[BbTestCase alloc]initWithName:self.className];
    [testCase2 setInputValue:@(-2) forInletAtIndex:0];
    [testCase2 setInputValue:@(4) forInletAtIndex:1];
    testCase2.expectedOutput = @(-0.5);
    testCase2.caseNumber = 2;
    [testCases addObject:testCase2];
    return testCases;
    return nil;
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
