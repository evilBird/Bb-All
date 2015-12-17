//
//  BbMessageTests.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BbMessage.h"

@interface BbMessageTests : XCTestCase

@end

@implementation BbMessageTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMessage
{
    BbMessage *message = [[BbMessage alloc]initWithArguments:@"Test"];
    message.mainOutlet.outputBlock = ^(id outputValue){
        NSLog(@"message output: %@",outputValue);
    };
    
    [[message hotInlet]input:[BbBang bang]];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
