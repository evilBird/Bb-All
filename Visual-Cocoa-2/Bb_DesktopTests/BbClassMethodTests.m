//
//  BbClassMethodTests.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BbClassMethod.h"
#import "BbInstanceMethod.h"
#import "NSObject+Bb.h"

@interface BbClassMethodTests : XCTestCase

@property (nonatomic,strong)BbClassMethod *classMethod;
@property (nonatomic,strong)BbInstanceMethod *instanceMethod;

@end

@implementation BbClassMethodTests

- (void)setUp {
    [super setUp];
    self.classMethod = [[BbClassMethod alloc]initWithArguments:nil];
    self.instanceMethod = [[BbInstanceMethod alloc]initWithArguments:nil];
    BbOutletOutputBlock outputBlock = ^(id outputValue){
        NSLog(@"\noutput: %@",outputValue);
    };
    self.classMethod.mainOutlet.outputBlock = [outputBlock copy];
    self.instanceMethod.mainOutlet.outputBlock = [outputBlock copy];
    [self.classMethod.mainOutlet connectToInlet:self.instanceMethod.coldInlet];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    //[self.instanceMethod tearDown];
    //[self.classMethod tearDown];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInstanceMethods
{
    [self doTestClass:@"NSMutableArray"
             selector:@"arrayWithArray:"
            arguments:@[@[@"Test",@"This"]]
       expectedOutput:@[@"Test",@"This"]];
    
    NSArray *instanceInput2 = @[@"objectAtIndex:",@(1)];
    [self.instanceMethod.hotInlet input:instanceInput2];
    id instanceOutput = [self.instanceMethod.mainOutlet getValue];
    XCTAssertNotNil(instanceOutput,@"FAIL: output is nil");
    //XCTAssertTrue([instanceOutput isEqualToArray:@[@"Test",@"This"]],@"FAIL: incorrect output");
}

- (void)testClassMethods
{
    [self doTestClass:@"NSString"
             selector:@"stringWithString:"
            arguments:@[@"Test"]
       expectedOutput:@"Test"];
    
    [self doTestClass:@"NSMutableArray"
             selector:@"arrayWithObject:"
            arguments:@[@"Test"]
       expectedOutput:@[@"Test"]];
}

- (void)doTestClass:(NSString *)className selector:(NSString *)selectorName arguments:(NSArray *)arguments expectedOutput:(id)expectedOutput;
{
    [self.classMethod.coldInlet input:className];
    NSMutableArray *hotInput = [NSMutableArray array];
    [hotInput addObject:selectorName];
    if (arguments) {
        [hotInput addObjectsFromArray:arguments];
    }
    
    [self.classMethod.hotInlet input:hotInput];
    
    id output = [self.classMethod.mainOutlet getValue];
    if (expectedOutput == nil) {
        XCTAssertNil(output,@"FAIL: output should be nil");
        return;
    }
    
    XCTAssert(output!=nil,@"FAIL: output is nil");
    
    if ([expectedOutput isKindOfClass:[NSString class]]) {
        XCTAssert([[output toString] isEqualToString:expectedOutput],@"FAIL: output %@ doesn't match expected output %@",output,expectedOutput);
    }else if ([expectedOutput isKindOfClass:[NSArray class]]){
        XCTAssert([output isEqualToArray:expectedOutput],@"FAIL: output %@ doesn't match expected output %@",output,expectedOutput);
    }else if ([expectedOutput isKindOfClass:[NSDictionary class]]){
        XCTAssert([output isEqualToDictionary:expectedOutput],@"FAIL: output %@ doesn't match expected output %@",output,expectedOutput);
    }else{
        XCTAssertTrue(output == expectedOutput,@"FAIL: output %@ doesn't match expected output %@",output,expectedOutput);
    }
    
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
