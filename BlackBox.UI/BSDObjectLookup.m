//
//  BSDObjectLookup.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObjectLookup.h"
#import <objc/runtime.h>
#import "NSUserDefaults+HBVUtils.h"

@interface BSDObjectLookup ()

@property (nonatomic,strong)NSDictionary *classDictionary;

@end

@implementation BSDObjectLookup

- (NSString *)classNameForString:(NSString *)string
{
    NSArray *keys = self.classDictionary.allKeys;
    NSString *lower = [string lowercaseString];
    if ([keys containsObject:lower]) {
        return self.classDictionary[lower];
    }
    
    NSString *query = [self processString:string];
    
    if ([keys containsObject:query]) {
        return self.classDictionary[query];
    }
    
    return nil;
}

- (NSString *)processString:(NSString *)string
{
    NSString *lower = [string lowercaseString];
    NSRange prefixRange = [lower rangeOfString:@"bsd"];
    if (prefixRange.length == 0) {
        return [@"bsd" stringByAppendingString:lower];
    }
    
    return lower;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *classes = [self classList];
        NSArray *patches = [self patchList];
        self.classDictionary = [self dictionaryWithClassList:classes patchList:patches];
        
    }
    
    return self;
}

- (NSDictionary *)dictionaryWithClassList:(NSArray *)classes patchList:(NSArray *)patches
{
    NSMutableDictionary *result = nil;
    for (NSString *aClass in classes) {
        NSString *key = [aClass lowercaseString];
        if (!result) {
            result = [NSMutableDictionary dictionary];
        }
        result[key] = aClass;

    }
    
    for (NSString *aPatch in patches) {
        NSString *key = [aPatch lowercaseString];
        if (!result) {
            result = [NSMutableDictionary dictionary];
        }
        
        result[key] = @"BSDCompiledPatch";
    }
    
    result[@"patch"] = @"BSDCompiledPatch";
    
    return result;
}

- (NSArray *)classList;
{
    unsigned outCount;
    Class *classes = objc_copyClassList(&outCount);
    NSMutableSet *result = nil;
    for (unsigned i = 0; i < outCount; i++) {
        Class theClass = classes[i];
        Class superClass = class_getSuperclass(theClass);
        NSString *className = NSStringFromClass(theClass);
        NSString *superClassName = NSStringFromClass(superClass);
        if ([superClassName isEqualToString:@"BSDObject"]) {
            
            if (!result) {
                result = [NSMutableSet set];
            }
            
            [result addObject:className];
        }
    }
    
    free(classes);
    return result.allObjects;
}

- (NSArray *)patchList
{
    NSDictionary *patches = [NSUserDefaults valueForKey:@"patches"];
    if (patches) {
        return patches.allKeys;
    }
    
    return nil;
}

@end
