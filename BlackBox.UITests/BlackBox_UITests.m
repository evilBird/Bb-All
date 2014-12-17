//
//  BlackBox_UITests.m
//  BlackBox.UITests
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSDiCloud.h"
#import "BSDObjects.h"

@interface BlackBox_UITests : XCTestCase

@property (nonatomic,strong)BSDObject *object;

@end

@implementation BlackBox_UITests

- (void)setUp {
    [super setUp];
    self.object = [[BSDiCloud alloc]initWithArguments:nil];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.object tearDown];
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testGetiCloudFileList
{
    [self.object.hotInlet input:kGetFileListSelectorKey];
    XCTAssertNotNil(self.object.mainOutlet.value,@"PASS");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
