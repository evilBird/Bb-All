//
//  BSDiCloud.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDiCloud.h"

typedef void(^iCloudCompletionBlock)(id result, NSError *error);
@interface BSDiCloud ()
{
    NSArray *kSelectorKeys;
    BOOL kCloudIsAvailable;
    id kUbiquityToken;
    NSURL *kUbiquityContainer;
}

@property (nonatomic,strong)iCloudCompletionBlock completionBlock;

@end

@implementation BSDiCloud

+ (NSData *)dataForPlistAtPath:(NSString *)path
{
    NSError *err = nil;
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSData *fileData = [NSPropertyListSerialization dataWithPropertyList:dictionary
                                                                  format:NSPropertyListXMLFormat_v1_0
                                                                 options:0
                                                                   error:&err];
    if (err) {
        return nil;
    }
    
    return fileData;
}

+ (NSDictionary *)plistWithData:(NSData *)data
{
    NSError *err = nil;
    NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&err];
    if (err) {
        return nil;
    }
    
    return plist;
}

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"iCloud";
    kSelectorKeys = @[kGetFileListSelectorKey,kDownloadFileSelectorKey,kUploadFileSelectorKey,kSynchronizeFileSelectorKey,kGetFileVersionSelectorKey];
    if (arguments) {
        [self.coldInlet input:arguments];
    }
}

- (void)calculateOutput
{
    [self doSelectorWithKey:self.hotInlet.value
                  arguments:self.coldInlet.value
            completionBlock:^(id result, NSError *error) {
                if (error) {
                    [self.mainOutlet output:error];
                }else{
                    [self.mainOutlet output:result];
                }
            }];
}



#pragma mark - Keyed selector implementations

- (void)doSelectorWithKey:(NSString *)selectorKey arguments:(id)arguments completionBlock:(void(^)(id result, NSError *error))completionBlock
{
    NSError *err = [self validateArgs:arguments forSelectorKey:selectorKey];
    if (err) {
        completionBlock(nil, err);
        return;
    }
    
    if ([selectorKey isEqualToString:kGetFileListSelectorKey]) {
        [self getFileListCompletion:completionBlock];
        return;
    }
    
    if ([selectorKey isEqualToString:kDownloadFileSelectorKey]) {
        [self downloadFileWithName:arguments completion:completionBlock];
        return;
    }
    
    if ([selectorKey isEqualToString:kUploadFileSelectorKey]) {
        [self uploadFileWithName:arguments[0] data:arguments[1] completion:completionBlock];
        return;
    }
    
    if ([selectorKey isEqualToString:kSynchronizeFileSelectorKey]) {
        [self synchronizeCloud];
        return;
    }
}

- (void)getFileListCompletion:(void(^)(id result, NSError *error))completion
{
    BOOL cloudAvailable = [[iCloud sharedCloud] checkCloudAvailability];
    if (!cloudAvailable) {
        NSError *err = [self iCloudErrorReason:@"iCloud is not available"];
        completion(nil,err);
        return;
    }
    
    BOOL cloudEnabled = [[NSUserDefaults standardUserDefaults]boolForKey:@"userCloudPref"];
    if (!cloudEnabled) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userCloudPref"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        cloudEnabled = [[NSUserDefaults standardUserDefaults]boolForKey:@"userCloudPref"];
        if (!cloudEnabled) {
            NSError *err = [self iCloudErrorReason:@"iCloud must be enabled for this app"];
            completion(nil,err);
            return;
        }
    }
    self.completionBlock = completion;
    iCloud *cloud = [iCloud sharedCloud];
    [cloud setDelegate:self];
    [cloud setVerboseLogging:YES];
    NSArray *fileNames = [cloud getListOfCloudFiles];
    NSError *err = nil;
    if (!fileNames) {
        err = [self iCloudErrorReason:@"no files exist in the cloud"];
    }
    completion(fileNames,err);
}

- (void)downloadFileWithName:(NSString *)fileName completion:(void(^)(id result, NSError *error))completion
{
    [[iCloud sharedCloud] retrieveCloudDocumentWithName:fileName completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (error == nil) {
            NSString *documentName = [cloudDocument.fileURL lastPathComponent];
            NSDictionary *dict = @{@"documentName":documentName,
                                   @"fileData":documentData,
                                   @"cloudDocument":cloudDocument
                                   };
            completion(dict,nil);
        }else{
            completion(nil, error);
        }
    }];
}

- (void)uploadFileWithName:(NSString *)fileName data:(NSData *)fileData completion:(void(^)(id result, NSError *error))completion
{
    [[iCloud sharedCloud] saveAndCloseDocumentWithName:fileName withContent:fileData completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (error == nil) {
            // Code here to use the UIDocument or NSData objects which have been passed with the completion handler
            NSDictionary *dict = @{@"documentName":fileName,
                                   @"fileData":documentData,
                                   @"cloudDocument":cloudDocument};
            completion(dict,nil);
        }else{
            completion(nil,error);
        }
    }];
}

- (void)synchronizeCloud
{
    [[iCloud sharedCloud]updateFiles];
}

#pragma mark - Keyed selector helper methods

- (NSError *)validateArgs:(id)args forSelectorKey:(NSString *)selectorKey
{
    NSError *err = nil;
    if (!selectorKey) {
        err = [[NSError alloc]initWithDomain:@"selector key" code:-1 userInfo:@{@"reason":@"selector key cannot be nil"}];
        return err;
    }
    if (![selectorKey isKindOfClass:[NSString class]]) {
        err = [[NSError alloc]initWithDomain:@"selector key" code:-1 userInfo:@{@"reason":@"selector key must be of type NSString"}];
        return err;
    }
    
    if (![kSelectorKeys containsObject:selectorKey]) {
        err = [[NSError alloc]initWithDomain:@"selector key" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"selector key '%@' not found",selectorKey]}];
        return err;
    }
    
    if ([selectorKey isEqualToString:kGetFileListSelectorKey]) {
        return nil;
    }
    
    if ([selectorKey isEqualToString:kDownloadFileSelectorKey]) {
        if (!args) {
            err = [[NSError alloc]initWithDomain:@"arguments" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"argument for selector %@ cannot be nil",selectorKey]}];
            return err;
        }
        if (![args isKindOfClass:[NSString class]]) {
            err = [[NSError alloc]initWithDomain:@"arguments" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"argument for selector %@ must be of type NSString",selectorKey]}];
            return err;
        }
        
        return nil;
    }
    
    if ([selectorKey isEqualToString:kUploadFileSelectorKey]) {
        
        if (!args) {
            err = [[NSError alloc]initWithDomain:@"arguments" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"argument for selector %@ cannot be nil",selectorKey]}];
            return err;
        }
        if (![args isKindOfClass:[NSArray class]]) {
            err = [[NSError alloc]initWithDomain:@"arguments" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"argument for selector %@ must be of type NSArray",selectorKey]}];
            return err;
        }
        
        if ([args count] != 2) {
            err = [[NSError alloc]initWithDomain:@"arguments" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"arguments for selector %@ must be of type NSArray containg 2 objects",selectorKey]}];
            return err;
        }
        
        if (![args[0] isKindOfClass:[NSString class]]) {
            err = [[NSError alloc]initWithDomain:@"arguments" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"argument at index 0 for selector %@ must be of type NSString",selectorKey]}];
            return err;
        }
        
        if (![args[1] isKindOfClass:[NSData class]]) {
            err = [[NSError alloc]initWithDomain:@"arguments" code:-1 userInfo:@{@"reason":[NSString stringWithFormat:@"argument at index 1 for selector %@ must be of type NSData",selectorKey]}];
            return err;
        }
        
        return nil;
    }
    
    if ([selectorKey isEqualToString:kSynchronizeFileSelectorKey]) {
        return nil;
    }
    
    return nil;
}

- (NSString *)generateFileNameWithExtension:(NSString *)extensionString {
    NSDate *time = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-hh-mm-ss"];
    NSString *timeString = [dateFormatter stringFromDate:time];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", timeString, extensionString];
    
    return fileName;
}

- (NSError *)iCloudErrorReason:(NSString *)reason
{
    NSError *err = [[NSError alloc]initWithDomain:@"iCloud" code:-1 userInfo:@{@"reason":reason}];
    return err;
}

- (BOOL)appIsRunningForFirstTime {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        // App already launched
        return NO;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        return YES;
    }
}


#pragma mark - iCloud Delegate

- (void)iCloudDidFinishInitializingWitUbiquityToken:(id)cloudToken withUbiquityContainer:(NSURL *)ubiquityContainer
{
    kUbiquityToken = cloudToken;
    kUbiquityContainer = ubiquityContainer;
}

- (void)iCloudAvailabilityDidChangeToState:(BOOL)cloudIsAvailable withUbiquityToken:(id)ubiquityToken withUbiquityContainer:(NSURL *)ubiquityContainer
{
    kCloudIsAvailable = cloudIsAvailable;
    kUbiquityToken = ubiquityToken;
    kUbiquityContainer = ubiquityContainer;
}

- (void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames {
    // Get the query results
    NSLog(@"files changed: %@",fileNames);
}

- (void)iCloudFileConflictBetweenCloudFile:(NSDictionary *)cloudFile andLocalFile:(NSDictionary *)localFile
{
    
}



@end
