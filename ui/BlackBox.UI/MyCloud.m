//
//  MyCloud.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "MyCloud.h"
#import "BSDiCloud.h"
#import "BSDPatchManager.h"

@implementation MyCloud

+ (MyCloud *)sharedCloud
{
    static MyCloud *_sharedCloud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCloud = [[MyCloud alloc]init];
    });
    
    return _sharedCloud;
}

+ (BOOL)plistExists:(NSString *)plist
{
    return [[iCloud sharedCloud]doesFileExistInCloud:[MyCloud fileNameForPlist:plist]];
}

+ (NSDate *)plistCreationDate:(NSString *)plist
{
    return [[iCloud sharedCloud]fileCreatedDate:[MyCloud fileNameForPlist:plist]];
}

+ (NSDate *)plistModifiedDate:(NSString *)plist
{
    return [[iCloud sharedCloud]fileCreatedDate:[MyCloud fileNameForPlist:plist]];
}

+ (NSString *)fileNameForPlist:(NSString *)plist
{
    if (!plist) {
        return nil;
    }
    
    return [plist stringByAppendingPathExtension:@"plist"];
}

- (void)getDocListCompletion:(void(^)(id result, NSError *err))completion
{
    BSDiCloud *cloud = [[BSDiCloud alloc]initWithArguments:nil];
    cloud.mainOutlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        id output = outlet.value;
        if (!output) {
            completion(nil,[NSError errorWithDomain:@"iCloud"
                                               code:-1
                                           userInfo:nil]);
        }else if ([output isKindOfClass:[NSError class]]){
            completion(nil, output);
        }else{
            completion(output,nil);
        }
    };
    
    [cloud.hotInlet input:kGetFileListSelectorKey];
}

- (void)uploadPlistNamed:(NSString *)plist completion:(void(^)(id result, NSError *err))completion
{
    NSString *docsPath = [BSDPatchManager documentsDirectoryPath];
    NSString *fileName = [plist stringByAppendingPathExtension:@"plist"];
    NSString *filePath = [docsPath stringByAppendingPathComponent:fileName];
    NSData *fileData = [BSDiCloud dataForPlistAtPath:filePath];
    NSArray *arguments = @[fileName,fileData];
    BSDiCloud *cloud = [[BSDiCloud alloc]initWithArguments:arguments];
    cloud.mainOutlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        id output = outlet.value;
        if (!output) {
            completion(nil, [NSError errorWithDomain:@"iCloud"
                                                code:-1
                                            userInfo:nil]);
        }else if ([output isKindOfClass:[NSError class]]){
            completion(nil, output);
        }else{
            completion(output,nil);
        }
    };
    
    [cloud.hotInlet input:kUploadFileSelectorKey];
}

- (void)downloadPlistNamed:(NSString *)plist completion:(void(^)(id result, NSError *err))completion
{
    NSString *fileName = [plist stringByAppendingPathExtension:@"plist"];
    BSDiCloud *cloud = [[BSDiCloud alloc]initWithArguments:fileName];
    cloud.mainOutlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        id output = outlet.value;
        if (!output) {
            completion(nil,[NSError errorWithDomain:@"iCloud"
                                               code:-1
                                           userInfo:nil]);
        }else if ([output isKindOfClass:[NSError class]]){
            completion(nil, output);
        }else{
            NSData *data = [output valueForKey:@"fileData"];
            NSDictionary *dict = [BSDiCloud plistWithData:data];
            completion(dict, nil);
        }
    };
    
    [cloud.hotInlet input:kDownloadFileSelectorKey];
}

- (void)sync
{
    BSDiCloud *cloud = [[BSDiCloud alloc]initWithArguments:nil];
    [cloud.hotInlet input:kSynchronizeFileSelectorKey];
}

- (void)syncFileName:(NSString *)fileName
{
    [self sync];
    [BSDPatchManager updateHistoryForFile:fileName];
}

@end
