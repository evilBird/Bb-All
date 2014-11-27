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

- (NSDictionary *)savedPatches;
- (void)savePatchDescription:(NSString *)patchDescription withName:(NSString *)name;
- (NSString *)getPatchNamed:(NSString *)name;
- (void)deleteItemAtPath:(NSString *)path;

- (NSDictionary *)importFromDocuments:(NSString *)fileName;
- (void) exportToDocuments:(NSDictionary *)dictionary fileName:(NSString *)fileName;

@end
