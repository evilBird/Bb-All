//
//  BSDFilterImageView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/2/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDImageFilter.h"
#import "GPUImage.h"
#import <objc/runtime.h>

@interface BSDImageFilter ()

@property (nonatomic,strong)GPUImageFilter *myFilter;
@property (nonatomic,strong)NSDictionary *filterDictionary;
@property (nonatomic,strong)NSString *filterName;

@end

@implementation BSDImageFilter

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"imageFilter";
    self.filterDictionary = [self getFilters];
    if (arguments) {
        NSString *filterName = nil;
        if ([arguments isKindOfClass:[NSString class]]) {
            filterName = arguments;
        }else if ([arguments isKindOfClass:[NSArray class]]){
            filterName = [arguments firstObject];
        }
        self.myFilter = [self filterForKey:filterName];
    }
}

- (GPUImageFilter *)filterForKey:(NSString *)key
{
    if (![self.filterDictionary.allKeys containsObject:[key lowercaseString]]) {
        return nil;
    }
    
    NSString *classString = [self.filterDictionary valueForKey:[key lowercaseString]];
    Class c = NSClassFromString(classString);
    GPUImageFilter *result = [[c alloc]init];
    return result;
}

- (void)applyParameters:(NSDictionary *)parameters toFilter:(id)filter
{
    NSMutableDictionary *parms = parameters.mutableCopy;
    if (parms.allKeys.count) {
        for (NSString *aKey in parms.allKeys) {
            id newValue = parms[aKey];
            [filter setValue:newValue forKey:aKey];
        }
    }
}

- (NSDictionary *)getFilters
{
    unsigned numClasses;
    Class * classes = NULL;
    
    numClasses = objc_getClassList(NULL, 0);
    classes = objc_copyClassList(&numClasses);
    NSMutableDictionary *filterDictionary = nil;
    for (NSUInteger i = 0; i < numClasses; i++) {
        NSString *class = [NSString stringWithUTF8String:class_getName(classes[i])];
        if ([[class lowercaseString] hasPrefix:@"gpuimage"] && [[class lowercaseString] hasSuffix:@"filter"]) {
            if (!filterDictionary) {
                filterDictionary = [NSMutableDictionary dictionary];
                filterDictionary[@"parameters"] = [NSMutableDictionary dictionary];
            }
            
            NSMutableString *alias = [NSMutableString stringWithString:[class lowercaseString]];
            NSRange range;
            range.location = 0;
            range.length = alias.length;
            [alias replaceOccurrencesOfString:@"gpuimage" withString:@"" options:0 range:range];
            range.length = alias.length;
            [alias replaceOccurrencesOfString:@"filter" withString:@"" options:0 range:range];
            NSString *filterAlias = [NSString stringWithString:alias];
            if (filterAlias.length > 0) {
                filterDictionary[filterAlias] = class;
                NSDictionary *map = [self propertyTypeMapForClassName:class];
                if (map){
                    filterDictionary[@"parameters"][filterAlias] = map.mutableCopy;
                }
            }
            
        }
    }
    return filterDictionary;
}

- (NSDictionary *)propertyTypeMapForClassName:(NSString *)className
{
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    @autoreleasepool {
        Class c = NSClassFromString(className);
        id instance = [[c alloc]init];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(c, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char * aname=property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:aname];
            NSString *propertyType = [self propertyType:propertyName onObject:instance];
            results[propertyName] = propertyType;
        }
        if (properties) {
            free(properties);
        }
        
    } // end of autorelease pool.
    return results;
}

- (NSString*) propertyType: (NSString*)propname onObject:(id)obj
{
    objc_property_t aproperty = class_getProperty([obj class],  [propname cStringUsingEncoding:NSASCIIStringEncoding] ); // how to get a specific one by name.
    if (aproperty)
    {
        char * property_type_attribute = property_copyAttributeValue(aproperty, "T");
        NSString *result = [NSString stringWithUTF8String:property_type_attribute];
        free(property_type_attribute);
        return result;
    }
    else
        return @"";
}


@end
