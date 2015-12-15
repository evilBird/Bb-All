//
//  Bb_Gesture_EngineTests.m
//  Bb Gesture EngineTests
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BbBlockMatrix+Helpers.h"
@interface Bb_Gesture_EngineTests : XCTestCase

@end

@implementation Bb_Gesture_EngineTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExpressionEvaluator
{
    id value = @(10);
    NSExpression *expression = [NSExpression expressionWithFormat:@"5 < %@",value];
    BbBlockMatrixEvaluator evaluator = [BbBlockMatrix evaluatorWithExpression:expression];
    NSNumber *result = evaluator(value);
    XCTAssertEqual(result.integerValue, 0);
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
