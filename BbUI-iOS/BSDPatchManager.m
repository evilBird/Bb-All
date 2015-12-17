//
//  BSDPatchManager.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPatchManager.h"
#import "MyCloud.h"
#import "NSUserDefaults+HBVUtils.h"

static NSString *kUpdateHistoryKey = @"com.birdSound.bb.updateHistoryDictionary";

static NSString *kLibName = @"bb_stdlib";

@interface BSDPatchManager ()

- (BOOL)stdLibIsInstalled;

@end

@implementation BSDPatchManager

+ (BSDPatchManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BSDPatchManager *_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BSDPatchManager alloc]init];
        
    });
    
    return _sharedInstance;
}

+ (NSString *)documentsDirectoryPath
{
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    
    if ([paths count] > 0)
    {
        // Path to save dictionary
        return [paths objectAtIndex:0];
    }
    
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentPlistName = kLibName;
    }
    
    return self;
}

- (NSArray *)allSavedPatchNames
{
    NSDictionary *saved = [self savedPatches];
    return [saved allPaths];
}

- (NSDictionary *)migrateOldPatches
{
    NSDictionary *patches = [NSUserDefaults valueForKey:@"descriptions"];
    NSDictionary *nested = [NSMutableDictionary nestedDictionaryWithDictionary:patches];
    return nested;
}

- (NSDictionary *)savedPatches
{
    return [self importFromDocuments:self.currentPlistName];
}

- (NSString *)getPatchNamed:(NSString *)name
{
    NSDictionary *saved = [self savedPatches];
    id obj = [saved objectAtKeyPath:name];    
    return obj;
}

- (void)savePatchDescription:(NSString *)patchDescription withName:(NSString *)name
{
    NSDictionary *saved = [self savedPatches];
    if (!saved) {
        saved = [[NSDictionary alloc]init];
    }
    
    NSMutableDictionary *copy = saved.mutableCopy;
    [copy addObject:patchDescription atKeyPath:name];
    saved = copy;
    [self exportToDocuments:saved fileName:self.currentPlistName];
}

- (void)deleteItemAtPath:(NSString *)path
{
    NSDictionary *saved = [self savedPatches];
    NSMutableDictionary *copy = saved.mutableCopy;
    [copy removeObjectAtKeyPath:path];
    saved = copy;
    [self exportToDocuments:saved fileName:self.currentPlistName];
}

- (void) exportToDocuments:(NSDictionary *)dictionary fileName:(NSString *)fileName
{
    NSString  *dictPath;
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    
    if ([paths count] > 0)
    {
        // Path to save dictionary
        NSString *filePath = [fileName stringByAppendingPathExtension:@"plist"];
        dictPath = [[paths objectAtIndex:0]
                    stringByAppendingPathComponent:filePath];
        
        // Write dictionary
        [dictionary.mutableCopy writeToFile:dictPath atomically:YES];
        [BSDPatchManager updateHistoryForFile:fileName];
    }
}

- (NSDictionary *)importFromDocuments:(NSString *)fileName
{
    NSString  *dictPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    
    if ([paths count] > 0)
    {
        // Path to dictionary
        NSString *filePath = [fileName stringByAppendingPathExtension:@"plist"];
        dictPath = [[paths objectAtIndex:0]
                    stringByAppendingPathComponent:filePath];
    }
    if (dictPath) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:dictPath];
        return dict;
    }
    
    return nil;

}

- (void)createStdLib
{
    
}

- (BOOL)stdLibIsInstalled
{
    return ([self savedPatches] != nil);
}

- (void)syncWithCloud
{
    [[MyCloud sharedCloud]syncFileName:self.currentPlistName];
}

- (BOOL)shouldPush
{
    return ([self timeSincePush] > 0.0);
}

- (BOOL)shouldPull
{
    return ([self timeSincePull] > 0.0);
}

- (void)push
{
    //TODO: push
    NSLog(@"PUSH!");
    [[MyCloud sharedCloud]uploadPlistNamed:self.currentPlistName completion:^(id result, NSError *err) {
        if (err) {
            NSLog(@"push failed");
        }else{
            NSLog(@"push succeeded");
        }
    }];
}

- (void)pull
{
    //TODO: pull
    NSLog(@"PULL!");
    [[MyCloud sharedCloud]downloadPlistNamed:self.currentPlistName completion:^(id result, NSError *err) {
        if (!err) {
            NSLog(@"pull succeeded");
            [self exportToDocuments:result fileName:self.currentPlistName];
        }else{
            NSLog(@"pull failed");
        }
    }];
}

- (NSInteger)diffCount
{
    return 0;
}

- (NSTimeInterval)timeSincePull
{
    NSDate *localDate = [BSDPatchManager lastUpdateForFile:self.currentPlistName];
    NSDate *cloudDate = [MyCloud plistModifiedDate:self.currentPlistName];
    NSTimeInterval diff = [cloudDate timeIntervalSinceDate:localDate];
    return diff;
}

- (NSTimeInterval)timeSincePush
{
    NSDate *localDate = [BSDPatchManager lastUpdateForFile:self.currentPlistName];
    NSDate *cloudDate = [MyCloud plistModifiedDate:self.currentPlistName];
    NSTimeInterval diff = [localDate timeIntervalSinceDate:cloudDate];
    return diff;
}
/*
- (void)update
{
    NSTimeInterval timeSincePush = [self timeSincePush];
    NSTimeInterval timeSincePull = [self timeSincePull];
    BOOL push = [self shouldPush];
    BOOL pull = [self shouldPull];
    if (push && !pull) {
        NSLog(@"%@ hours since push",@(timeSincePush/3600.0));
        [self push];
        return;
    }
    if (pull && !push){
        NSLog(@"%@ hours since pull",@(timeSincePull/3600.0));
        [self pull];
        return;
    }
    
    if ((!push && !pull) || (push && pull)) {
        NSLog(@"what the fuck");
    }
}
*/
- (void)update
{
    [[MyCloud sharedCloud]syncFileName:self.currentPlistName];
}
+ (void)updateHistoryForFile:(NSString *)fileName
{
    NSDictionary *savedDictionary = [NSUserDefaults valueForKey:kUpdateHistoryKey];
    NSMutableDictionary *fileHistoryDictionary = nil;
    if (!savedDictionary) {
        fileHistoryDictionary = [NSMutableDictionary dictionary];
    }else{
        fileHistoryDictionary = savedDictionary.mutableCopy;
    }
    
    [fileHistoryDictionary setValue:[NSDate date] forKey:fileName];
    [NSUserDefaults setUserValue:fileHistoryDictionary forKey:kUpdateHistoryKey];
}

+ (NSDate *)lastUpdateForFile:(NSString *)fileName
{
    NSMutableDictionary *fileHistoryDictionary = [NSUserDefaults valueForKey:kUpdateHistoryKey];
    if (!fileHistoryDictionary) {
        return nil;
    }
    
    return [fileHistoryDictionary valueForKey:fileName];
}

@end
