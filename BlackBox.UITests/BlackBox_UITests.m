//
//  BlackBox_UITests.m
//  BlackBox.UITests
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSDiCloud.h"
#import "BSDPatchManager.h"

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

- (void)testCloudListDocs
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"cloud get doc list"];
    self.object = [[BSDiCloud alloc]initWithArguments:nil];
    self.object.mainOutlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        [expectation fulfill];
        id output = outlet.value;
        XCTAssertNotNil(output,@"cloud doc list response should not be nil");
        XCTAssertTrue([output isKindOfClass:[NSArray class]],@"cloud doc list should be of type NSArray");
    };
    [self.object.hotInlet input:kGetFileListSelectorKey];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"cloud list docs time out error");
        }
    }];
}

- (void)testCloudUpload
{
    NSString *docsPath = [BSDPatchManager documentsDirectoryPath];
    NSString *fileName = @"bb_stdlib.plist";
    NSString *filePath = [docsPath stringByAppendingPathComponent:fileName];
    NSData *fileData = [BSDiCloud dataForPlistAtPath:filePath];
    NSArray *arguments = @[fileName,fileData];
    XCTestExpectation *expectation = [self expectationWithDescription:@"iCloud upload"];
    self.object = [[BSDiCloud alloc]initWithArguments:arguments];
    self.object.mainOutlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        [expectation fulfill];
        NSDictionary *output = outlet.value;
        XCTAssertNotNil(output,@"cloud upload response dictionary should not be nil");
        NSData *data = output[@"documentData"];
        XCTAssertNotNil(data,@"cloud upload response document data should not be nil");
        NSDictionary *plist = [BSDiCloud plistWithData:data];
        NSDictionary *oldPlist = [NSDictionary dictionaryWithContentsOfFile:filePath];
        XCTAssertEqual(plist.allKeys.count, oldPlist.allKeys.count,@"old plist should have same number of keys as old plist");
        
        for (NSInteger i = 0; i < plist.allKeys.count; i++) {
            NSString *newKey = plist.allKeys[i];
            NSString *oldKey = oldPlist.allKeys[i];
            XCTAssertTrue([newKey isEqualToString:oldKey],@"new keys much match old keys");
            id newValue = [plist valueForKey:newKey];
            id oldValue = [oldPlist valueForKey:oldKey];
            XCTAssertTrue([newValue isKindOfClass:[oldValue class]],@"new value types must match old value types");
        }
    };

    [self.object.hotInlet input:kUploadFileSelectorKey];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"cloud upload time out error: %@",error);
        }
    }];
}

- (void)testCloudDownload
{
    NSString *docsPath = [BSDPatchManager documentsDirectoryPath];
    NSString *fileName = @"bb_stdlib.plist";
    self.object = [[BSDiCloud alloc]initWithArguments:fileName];
    XCTestExpectation *expectation = [self expectationWithDescription:@"cloud download"];
    self.object.mainOutlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        [expectation fulfill];
        NSDictionary *output = outlet.value;
        XCTAssertNotNil(output,@"cloud download output should not be nil");
        NSString *documentName = [output valueForKey:@"documentName"];
        XCTAssertTrue([fileName isEqualToString:documentName],@"cloud downloaded doc name %@ should be equal to queried name %@",documentName,fileName);
        NSData *data = [output valueForKey:@"fileData"];
        XCTAssertNotNil(data,@"cloud download file data must not be nil");
        NSDictionary *dict = [BSDiCloud plistWithData:data];
        XCTAssertNotNil(dict,@"cloud download plist must not be nil");
        XCTAssertTrue([dict isKindOfClass:[NSDictionary class]],@"cloud download plist must be of type NSDictionary");
        XCTAssertTrue(dict.allKeys.count > 0,@"cloud download plist should have at least 1 key");
        
    };
    [self.object.hotInlet input:kDownloadFileSelectorKey];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"cloud download timed out: %@",error);
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
