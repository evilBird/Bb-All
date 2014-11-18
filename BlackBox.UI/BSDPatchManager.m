//
//  BSDPatchManager.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPatchManager.h"

static NSString *kLibName = @"bb_stdlib";

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSDictionary *saved = [self savedPatches];
        if (!saved) {
            saved = [self migrateOldPatches];
            [self exportToDocuments:saved fileName:kLibName];
        }
    }
    
    return self;
}

- (NSDictionary *)migrateOldPatches
{
    NSDictionary *patches = [NSUserDefaults valueForKey:@"descriptions"];
    NSDictionary *nested = [NSMutableDictionary nestedDictionaryWithDictionary:patches];
    return nested;
}

- (NSDictionary *)savedPatches
{
    return [self importFromDocuments:kLibName];
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
    NSMutableDictionary *copy = saved.mutableCopy;
    [copy addObject:patchDescription atKeyPath:name];
    saved = copy;
    [self exportToDocuments:saved fileName:kLibName];
}

- (void)deleteItemAtPath:(NSString *)path
{
    NSDictionary *saved = [self savedPatches];
    NSMutableDictionary *copy = saved.mutableCopy;
    [copy removeObjectAtKeyPath:path];
    saved = copy;
    [self exportToDocuments:saved fileName:kLibName];
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
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:dictPath];
    return dict;
}

@end
