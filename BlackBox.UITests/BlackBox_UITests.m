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
#import "MyCloud.h"
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

- (void)testPinToSuper
{
    BSDPinEdgeToSuper *obj = [[BSDPinEdgeToSuper alloc]init];
    [obj.hotInlet input:@(1)];
    InstallConstraintsOnViewBlock block = [obj.mainOutlet.value copy];
    XCTAssertNotNil(block,@"block should not be nil");
    block(nil,nil,nil);
}

- (void)testClassMethod
{
    BSDClassMethod *cls = [[BSDClassMethod alloc]initWithArguments:nil];
    [cls.argumentsInlet input:@[[@"http://www.google.com" stringByReplacingPercentEscapesUsingEncoding:4]]];
    [cls.selectorInlet input:@"URLWithString:"];
    [cls.coldInlet input:@"NSURL"];
    [cls.hotInlet input:[BSDBang bang]];
    id output = cls.mainOutlet.value;
    
    XCTAssertNotNil(output,@"output should not be nil");
    XCTAssertTrue([output isKindOfClass:[NSURL class]],@"Output should be NSURL");
    NSLog(@"URL: %@",output);
    
}

- (void)testCreateURL
{
    BSDFactory *factory = [[BSDFactory alloc]initWithArguments:nil];
    factory.debug = YES;
    [factory.creationArgsInlet input: @"http://www.google.com"];
    [factory.selectorInlet input:@"initWithString:"];
    [factory.classNameInlet input:@"NSURL"];
    [factory.hotInlet input:[BSDBang bang]];
    id output = [[factory.mainOutlet value]copy];
    XCTAssertNotNil(output,@"Output should not be nil");
    XCTAssertTrue([output isKindOfClass:[NSURL class]],@"Output should be NSURL");
}

- (void)testCreateURLRequest
{
    BSDFactory *factory = [[BSDFactory alloc]initWithArguments:nil];
    factory.debug = YES;
    [factory.creationArgsInlet input: @"http://www.google.com"];
    [factory.selectorInlet input:@"initWithString:"];
    [factory.classNameInlet input:@"NSURL"];
    [factory.hotInlet input:[BSDBang bang]];
    id output = [[factory.mainOutlet value]copy];
    XCTAssertNotNil(output,@"Output should not be nil");
    XCTAssertTrue([output isKindOfClass:[NSURL class]],@"Output should be NSURL");
    
    [factory.creationArgsInlet input:output];
    [factory.selectorInlet input:@"initWithURL:"];
    [factory.classNameInlet input:@"NSURLRequest"];
    [factory.hotInlet input:[BSDBang bang]];
    
    id request = [[factory.mainOutlet value]copy];
    XCTAssertNotNil(request,@"output should not be nil");
    XCTAssertTrue([request isKindOfClass:[NSURLRequest class]],@"output should be NSURLRequest");
    
    UIWebView *webview = [[UIWebView alloc]init];
    [webview loadRequest:request];
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

- (void)testCloudSync
{
    NSArray *localKeys = [BSDPatchManager sharedInstance].savedPatches.allKeys;
    [[MyCloud sharedCloud]sync];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test cloud sync"];
    [[MyCloud sharedCloud]downloadPlistNamed:@"bb_stdlib" completion:^(id result, NSError *err) {
        [expectation fulfill];
        if (err) {
            XCTFail(@"failed to download plist: %@",err);
        }
        
        XCTAssertTrue([result isKindOfClass:[NSDictionary class]],@"download plist must return a dictionary");
        NSDictionary *plist = result;
        NSArray *cloudKeys = plist.allKeys;
        NSSet *cloudSet = [NSMutableSet setWithArray:cloudKeys];
        NSMutableSet *localSet = [NSMutableSet setWithArray:localKeys];
        [localSet minusSet:cloudSet];
        XCTAssertTrue(localSet.allObjects.count == 0, @"local and cloud plists should be the same");
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"cloud sync test timed out: %@",error);
        }
    }];
    
}

- (void)testCloudChangeThenSync
{
    NSArray *startKeys = [[BSDPatchManager sharedInstance]savedPatches].allKeys;
    if ([startKeys containsObject:@"TEST_NAME"]) {
        [[BSDPatchManager sharedInstance]deleteItemAtPath:@"TEST_NAME"];
        startKeys = [[BSDPatchManager sharedInstance]savedPatches].allKeys;
    }
    
    NSLog(@"start keys: %@",startKeys);
    [[BSDPatchManager sharedInstance]savePatchDescription:@"TEST_DESCRIPTION" withName:@"TEST_NAME"];
    [[MyCloud sharedCloud]sync];
    XCTestExpectation *expectation = [self expectationWithDescription:@"test cloud sync"];
    [[MyCloud sharedCloud]downloadPlistNamed:@"bb_stdlib" completion:^(id result, NSError *err) {
        [expectation fulfill];
        if (err) {
            XCTFail(@"failed to download plist: %@",err);
        }
        
        XCTAssertTrue([result isKindOfClass:[NSDictionary class]],@"download plist must return a dictionary");
        NSDictionary *plist = result;
        NSArray *downloadedKeys = plist.allKeys;
        NSMutableSet *downloadedSet = [NSMutableSet setWithArray:downloadedKeys];
        NSSet *startSet = [NSSet setWithArray:startKeys];
        [downloadedSet minusSet:startSet];
        NSLog(@"downloaded set: %@",downloadedSet);
        XCTAssertTrue(downloadedSet.allObjects.count == 1, @"downloaded plist should have 1 more key than original plist");
        NSString *newKey = downloadedSet.allObjects.firstObject;
        XCTAssertTrue([newKey isEqualToString:@"TEST_NAME"],@"added key %@ should be TEST_KEY",newKey);
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"cloud sync test timed out: %@",error);
        }
    }];
    
}

- (void)testCloudSyncThenChange
{
    [[MyCloud sharedCloud]sync];
    if ([[[BSDPatchManager sharedInstance]savedPatches].allKeys containsObject:@"TEST_NAME"]) {
        [[BSDPatchManager sharedInstance]deleteItemAtPath:@"TEST_NAME"];
    }
    
    [[MyCloud sharedCloud]sync];
    [[BSDPatchManager sharedInstance]savePatchDescription:@"TEST_DESCRIPTION" withName:@"TEST_NAME"];
    NSArray *localKeys = [BSDPatchManager sharedInstance].savedPatches.allKeys;
    XCTestExpectation *expectation = [self expectationWithDescription:@"test cloud sync"];
    [[MyCloud sharedCloud]downloadPlistNamed:@"bb_stdlib" completion:^(id result, NSError *err) {
        [expectation fulfill];
        if (err) {
            XCTFail(@"failed to download plist: %@",err);
        }
        
        XCTAssertTrue([result isKindOfClass:[NSDictionary class]],@"download plist must return a dictionary");
        NSDictionary *plist = result;
        NSArray *cloudKeys = plist.allKeys;
        NSSet *cloudSet = [NSMutableSet setWithArray:cloudKeys];
        NSMutableSet *localSet = [NSMutableSet setWithArray:localKeys];
        [localSet minusSet:cloudSet];
        XCTAssertTrue(localSet.allObjects.count == 1, @"local plist should have 1 more key than cloud plist");
        NSString *newKey = localSet.allObjects.firstObject;
        XCTAssertTrue([newKey isEqualToString:@"TEST_NAME"],@"local extra key %@ should be TEST_KEY",newKey);
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"cloud sync test timed out: %@",error);
        }
    }];
    
}

- (void)testExpressionObject
{
    BSDExpression *exp = [[BSDExpression alloc]initWithArguments:nil];
    NSString *format = @"%K > 5";
    NSArray *args = @[@"value",@(5)];
    NSDictionary *object = @{@"value":@(10)};
    exp.argsInlet.value = args;
    exp.coldInlet.value = format;
    [exp.hotInlet input:object];
    id output = exp.mainOutlet.value;
    XCTAssertTrue(([output integerValue] == 1),@"OUTPUT SHOULD EQUAL 1 NOT %@",output);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
