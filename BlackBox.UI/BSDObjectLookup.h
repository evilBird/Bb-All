//
//  BSDObjectLookup.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@interface NSObject (BSD)

+ (NSArray *)subclassList;
+ (NSArray *)allKeys;
+ (NSArray *)allMethodSigs;
+ (NSArray *)allMethodNames;

@end

@implementation NSObject (BSD)

+ (NSArray *)subclassList
{
    unsigned count;
    Class *buffer = objc_copyClassList(&count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < count; i++)
    {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while(superclass)
        {
            if(superclass == self)
            {
                [array addObject: candidate];
                break;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    free(buffer);
    return array;
}

+ (NSArray *)allKeys
{
    NSMutableArray *result = nil;
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (!result) {
            result = [NSMutableArray array];
        }
        NSRange ur = [key rangeOfString:@"_"];
        if (ur.length == 0) {
            [result addObject:key];
        }
    }
    free(properties);
    return result;
}

+ (NSArray *)allMethodSigs
{
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++){
        Method m = methods[i];
        NSString *name = [NSString stringWithUTF8String: method_getTypeEncoding(m)];
        [array addObject:name];
    }
    free(methods);
    return array;
}

+ (NSArray *)allMethodNames
{
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++){
        Method m = methods[i];
        SEL sel = method_getName(m);
        NSString *name = NSStringFromSelector(sel);
        NSRange ur = [name rangeOfString:@"_"];
        if (ur.length == 0) {
            [array addObject:name];
        }
    }
    free(methods);
    return array;
}

@end

@interface BSDObjectLookup : NSObject

- (NSString *)classNameForString:(NSString *)string;
- (NSArray *)classList;
- (NSArray *)patchList;

@end
