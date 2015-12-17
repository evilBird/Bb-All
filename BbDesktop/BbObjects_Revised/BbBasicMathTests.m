//
//  BbBasicMathTests.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBasicMathTests.h"
#import "BbTests.h"

@implementation BbAdd (Tests)

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

@implementation BbSubtract (Tests)


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

@implementation BbMultiply (Tests)


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

@implementation BbDivide (Tests)


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

@implementation BbMod (Tests)

@end

@implementation BbPow (Tests)

@end

@implementation BbSqrt (Tests)

@end

@implementation BbRoot (Tests)

@end

@implementation BbLog10 (Tests)

@end

@implementation BbLog2 (Tests)

@end

@implementation BbLogNat (Tests)

@end