//
//  NSDictionary+BSDUtils.h
//  BSDAnnotationClustering
//
//  Created by Travis Henspeter on 6/12/14.
//  Copyright (c) 2014 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BSDUtils)

- (NSDictionary *)dictionaryAtKeyPath:(NSString *)keyPath;
- (void)insertObject:(id)object atKeyPath:(NSString *)keyPath;
- (id)objectAtKeyPath:(NSString *)keyPath;
- (NSString *)printNestedKeys;
- (BOOL)dictionaryExistsAtKeyPath:(NSString *)keyPath;
+ (NSString *)pathWithComponents:(NSArray *)components;

@end

@interface NSMutableDictionary (BSDUtils)

+ (NSDictionary *)nestedDictionaryWithDictionary:(NSDictionary *)dictionary;
- (void)addObject:(id)object atKeyPath:(NSString *)keyPath;
- (void)removeObjectAtKeyPath:(NSString *)keyPath;

@end