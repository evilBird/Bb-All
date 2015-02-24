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
    NSLog(@"parsed message to string: %@",message);
}

- (void)testParseMessageToArray
{
    NSString *text = @"this these those";
    id message = [BbMessageParser messageFromText:text];
    XCTAssertNotNil(message,@"message is nil");
    NSLog(@"parsed message to array: %@",message);
}

- (void)testParseMessageToMulipleArrays
{
    NSString *text = @"this these, those";
    id message = [BbMessageParser messageFromText:text];
    XCTAssertNotNil(message,@"message is nil");
    NSLog(@"parsed message to multiple arrays: %@",message);
    
    text = @"this, these, those";
    message = [BbMessageParser messageFromText:text];
    XCTAssertNotNil(message,@"message is nil");
    NSLog(@"parsed message to multiple arrays: %@",message);
}

- (void)testParseMessageToStringWithCommas
{
    NSString *text = @"\"this these, those\"";
    id message = [BbMessageParser messageFromText:text];
    XCTAssertNotNil(message,@"message is nil");
    NSLog(@"parsed message to string with commas: %@",message);
}

- (void)testSetStringType
{
    NSString *text = @"44.978";
    id message = [BbMessageParser setTypeForString:text];
    XCTAssertNotNil(message,@"message is nil");
    XCTAssertTrue([message isKindOfClass:[NSNumber class]],@"message is not a number: %@",message);
    NSLog(@"set string %@ to double %@",text,message);
    
    text = @"44";
    message = [BbMessageParser setTypeForString:text];
    XCTAssertNotNil(message,@"message is nil");
    XCTAssertTrue([message isKindOfClass:[NSNumber class]],@"message is not a number: %@",message);
    NSLog(@"set string %@ to integer %@",text,message);
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
