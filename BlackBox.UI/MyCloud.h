//
//  MyCloud.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyCloud : NSObject

+ (MyCloud *)sharedCloud;

+ (BOOL)plistExists:(NSString *)plist;
+ (NSDate *)plistCreationDate:(NSString *)plist;
+ (NSDate *)plistModifiedDate:(NSString *)plist;

- (void)getDocListCompletion:(void(^)(id result, NSError *err))completion;
- (void)uploadPlistNamed:(NSString *)plist completion:(void(^)(id result, NSError *err))completion;
- (void)downloadPlistNamed:(NSString *)plist completion:(void(^)(id result, NSError *err))completion;
- (void)sync;
- (void)syncFileName:(NSString *)fileName;

@end
