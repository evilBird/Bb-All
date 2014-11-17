//
//  BlackBoxCategories.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//
#import <Foundation/Foundation.h>


#ifndef BlackBox_UI_BlackBoxCategories_h
#define BlackBox_UI_BlackBoxCategories_h


@interface NSDictionary (BlackBox)

+ (NSDictionary *)saveText:(NSString *)text path:(NSString *)path dictionary:(NSDictionary *)dictionary;
- (BOOL)valueForKeyIsDictionary:(id)aKey;
- (BOOL)keyIsDefined:(id)aKey;

@end

@implementation NSDictionary (BlackBox)

+ (NSDictionary *)saveText:(NSString *)text path:(NSString *)path dictionary:(NSDictionary *)dictionary;
{
    if (!text || !path) {
        return nil;
    }
    
    NSArray *pathComponents = [text componentsSeparatedByString:@"."];
    NSMutableDictionary *result = nil;
    
    if (dictionary == nil) {
        result = [NSMutableDictionary dictionary];
    }else{
        result = dictionary.mutableCopy;
    }
    
    if (pathComponents.count == 0) {
        return result;
    }
    
    if (pathComponents.count == 1) {
        result[pathComponents.firstObject] = text;
        return result;
    }
    
    for (NSString *component in pathComponents) {
        
    }
    
    return nil;
}

- (id)insertObject:(id)object inDictionary:(NSMutableDictionary*)dictionary atPathWithComponents:(NSArray *)components
{
    if (components.count == 0) {
        return dictionary;
    }
    
    NSString *currentComponent = components.firstObject;
    NSMutableArray *newArray = components.mutableCopy;
    [newArray removeObject:currentComponent];
    if (![dictionary keyIsDefined:currentComponent]) {
        
    }
    
    return nil;
}


- (BOOL)keyIsDefined:(id)aKey
{
    if (aKey == nil){
        return NO;
    }
    
    return [self.allKeys containsObject:aKey];
}

- (BOOL)valueForKeyIsDictionary:(id)aKey
{
    if (aKey == nil || ![self keyIsDefined:aKey]){
        return NO;
    }
    
    id value = self[aKey];
    return [value isKindOfClass:[NSDictionary class]];
    
    return NO;
}


@end

#endif
