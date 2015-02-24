//
//  BbMessageParserTests.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BbMessageParser.h"

@interface BbMessageParserTests : XCTestCase



@end

@implementation BbMessageParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseMessageToString
{
    NSString *text = @"\"Quotes with spaces\"";
    id message = [BbMessageParser messageFromText:text];
    XCTAssertNotNil(message,@"message is nil");
}

- (void)testParseMessageToArray
{
    NSString *text = @"this these those";
    id message = [BbMessageParser messageFromText:text];
    XCTAssertNotNil(message,@"message is nil");
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
