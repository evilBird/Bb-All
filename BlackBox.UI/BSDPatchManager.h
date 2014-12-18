//
//  BSDPatchManager.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+BSDUtils.h"

@interface BSDPatchManager : NSObject

+ (BSDPatchManager *)sharedInstance;

@property (nonatomic,strong)NSString *workingPath;

+ (NSString *)documentsDirectoryPath;
+ (void)updateHistoryForFile:(NSString *)fileName;
+ (NSDate *)lastUpdateForFile:(NSString *)fileName;

@property (nonatomic,strong)NSString *currentPlistName;

- (NSDictionary *)savedPatches;
- (NSArray *)allSavedPatchNames;
- (void)savePatchDescription:(NSString *)patchDescription withName:(NSString *)name;
- (NSString *)getPatchNamed:(NSString *)name;
- (void)deleteItemAtPath:(NSString *)path;
- (NSDictionary *)importFromDocuments:(NSString *)fileName;
- (void) exportToDocuments:(NSDictionary *)dictionary fileName:(NSString *)fileName;
- (void) syncWithCloud;
- (NSTimeInterval)timeSincePull;
- (NSTimeInterval)timeSincePush;
- (BOOL)shouldPush;
- (BOOL)shouldPull;
- (void)push;
- (void)pull;
- (NSInteger)diffCount;
- (void)update;

@end
