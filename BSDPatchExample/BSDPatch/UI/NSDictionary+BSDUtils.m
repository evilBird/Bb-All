//
//  NSDictionary+BSDUtils.m
//  BSDAnnotationClustering
//
//  Created by Travis Henspeter on 6/12/14.
//  Copyright (c) 2014 Theodore Calmes. All rights reserved.
//

#import "NSDictionary+BSDUtils.h"

@implementation NSDictionary (BSDUtils)

- (NSString *)printNestedKeys
{
    NSMutableString *result = [[NSMutableString alloc]init];
    NSArray *keys = [self allKeys];
    for (NSString *aKey in keys) {
        id value = self[aKey];
        [result appendFormat:@"\n"];
        [result appendFormat:@"%@",aKey];
        if ([value isKindOfClass:[NSDictionary class]]) {
            [result appendFormat:@"\t"];
            [result appendString:[value printNestedKeys]];
        }
    }
    
    return result;
}

- (void)insertObject:(id)object atKeyPath:(NSString *)keyPath
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    __block NSMutableDictionary *currentDictionary = self.mutableCopy;
    for (NSString *aKey in keys) {
        if (aKey == keys.lastObject) {
            currentDictionary[aKey] = object;
        }else{
            currentDictionary = [self dictionaryForKey:aKey inDictionary:currentDictionary];
        }
    }
}

- (NSMutableDictionary *)dictionaryForKey:(NSString *)key inDictionary:(NSMutableDictionary *)dictionary
{
    if ([dictionary.allKeys containsObject:key]) {
        return dictionary[key];
    }else{
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        dictionary[key] = newDictionary;
        return dictionary[key];
    }
}

- (NSDictionary *)dictionaryAtKeyPath:(NSString *)keyPath
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    __block NSDictionary *result = self;
    for (NSInteger idx = 0; idx < keys.count; idx ++) {
        result = result[keys[idx]];
    }
    
    return result;
}

- (id) objectAtKeyPath:(NSString *)keyPath
{
    if (keyPath == nil) {
        return self;
    }
    
    NSMutableArray *components = [keyPath componentsSeparatedByString:@"."].mutableCopy;
    NSString *lastComponent = components.lastObject;
    NSString *lastKey = nil;
    if ([lastComponent isEqualToString:@"bb"]) {
        [components removeLastObject];
        lastKey = [components.lastObject stringByAppendingPathExtension:lastComponent];
    }
    
    NSArray *keys = components;
    __block NSDictionary *result = self;
    for (NSInteger idx = 0; idx < keys.count; idx ++) {
        NSString *currentKey = keys[idx];
        result = result[currentKey];
    }
    
    if (!lastKey) {
        return result;
    }else{
        return result[lastKey];
    }
    
    return nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    if ([self.allKeys containsObject:key]) {
        return self[key];
    }
    return nil;
}


- (BOOL)dictionaryExistsAtKeyPath:(NSString *)keyPath
{
    if (keyPath.length == 0) {
        return NO;
    }
    
    NSArray *allKeys = [self allKeys];
    NSMutableArray *pathComponents = [keyPath componentsSeparatedByString:@"."].mutableCopy;
    if ([allKeys containsObject:pathComponents.firstObject]) {
        id value = self[pathComponents.firstObject];
        if ([value isKindOfClass:[NSDictionary class]]) {
            if (pathComponents.count == 1) {
                return YES;
            }
            NSString *formattedComponent = [NSString stringWithFormat:@"%@.",pathComponents.firstObject];
            NSRange toTrim = [keyPath rangeOfString:formattedComponent];
            NSString *trimmedPath = [keyPath stringByReplacingCharactersInRange:toTrim withString:@""];
            return [value dictionaryExistsAtKeyPath:trimmedPath];
            
        }else{
            return NO;
        }
    }
    return NO;
}

+ (NSString *)pathWithComponents:(NSArray *)components
{
    if (!components) {
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc]init];
    for (NSString *comp in components) {
        [result appendFormat:@"%@.",comp];
    }
    
    NSRange toTrim;
    toTrim.location = result.length - 1;
    toTrim.length = 1;
    
    return [result stringByReplacingCharactersInRange:toTrim withString:@""];
}

@end

@implementation NSMutableDictionary (BSDUtils)


+ (NSDictionary *)nestedDictionaryWithDictionary:(NSDictionary *)dictionary
{
    NSArray *allKeys = [dictionary allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *keyPath in sortedKeys) {
        id value = dictionary[keyPath];
        [result addObject:value atKeyPath:keyPath];
    }
    
    return result;
}

- (void)removeObjectAtKeyPath:(NSString *)keyPath
{
    NSMutableArray *components = [keyPath componentsSeparatedByString:@"."].mutableCopy;
    NSString *relativePath = nil;
    if ([components.lastObject isEqualToString:@"bb"]) {
        id component1 = components.lastObject;
        [components removeLastObject];
        if (components.count > 1) {
            id component2 = components.lastObject;
            [components removeLastObject];
            relativePath = [NSDictionary pathWithComponents:@[component1, component2]];
        }else{
            relativePath = keyPath;
            components = nil;
        }
    }else{
        relativePath = components.lastObject;
        [components removeLastObject];
    }
    NSString *parentPath = nil;
    
    
    if (components != nil && components.count > 0) {
        parentPath = [NSDictionary pathWithComponents:components];
        if ([[self objectAtKeyPath:parentPath] isKindOfClass:[NSDictionary class]]) {
            [[self objectAtKeyPath:parentPath]removeObjectForKey:relativePath];
        }else{
            NSLog(@"parent is not a dictionary...fuck");
        }
    }else{
        
        [self removeObjectForKey:relativePath];
    }

}



- (void)addObject:(id)object atKeyPath:(NSString *)keyPath
{
    NSArray *allKeys = self.allKeys;
    NSArray *pathComponents = [keyPath componentsSeparatedByString:@"."];
    //Is the dictionary a leaf?
    if (pathComponents.count == 1) {
        //Path is a leaf. Add .bb path extension
        BOOL fileExistsAtPath = [self.allKeys containsObject:pathComponents.firstObject];
        if (!fileExistsAtPath) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            self[pathComponents.firstObject] = dictionary;
            NSString *leafKey = [NSString stringWithFormat:@"%@.bb",pathComponents.firstObject];
            dictionary[leafKey] = object;
            return;
        }else{
            id existingFile = self[pathComponents.firstObject];
            if ([existingFile isKindOfClass:[NSDictionary class]]) {
                NSString *leafKey = [NSString stringWithFormat:@"%@.bb",pathComponents.firstObject];
                self[pathComponents.firstObject][leafKey] = object;
                return;
            }else if ([existingFile isKindOfClass:[NSString class]]){
                NSLog(@"the file at that path is a string");
                return;
            }
        }
    }
    
    //Dictionary is not a leaf, there are at least 2 path components
    //The first component might key dictionary, or nil
    BOOL dictExists = [allKeys containsObject:pathComponents.firstObject];
    //If first component is nil, we'll make a new dictionary
    if (!dictExists) {
        self[pathComponents.firstObject] = [[NSMutableDictionary alloc]init];
    }
    //Trim the path and add object to the next nested level
    NSString *trimmedPath = [self trimFirstComponentFromPath:keyPath];
    [self[pathComponents.firstObject]addObject:object atKeyPath:trimmedPath];
}

- (NSString *)trimFirstComponentFromPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"."];
    if (components.count == 1) {
        return nil;
    }
    
    NSString *formattedComponent = [NSString stringWithFormat:@"%@.",components.firstObject];
    NSRange toTrim = [path rangeOfString:formattedComponent];
    NSString *trimmedPath = [path stringByReplacingCharactersInRange:toTrim withString:@""];
    return trimmedPath;
}

- (NSString *)trimLastComponentFromPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"."];
    if (components.count == 1) {
        return nil;
    }
    NSString *formattedComponent = [NSString stringWithFormat:@"%@.",components.lastObject];
    NSRange toTrim = [path rangeOfString:formattedComponent];
    NSString *trimmedPath = [path stringByReplacingCharactersInRange:toTrim withString:@""];
    return trimmedPath;
    
}


@end
