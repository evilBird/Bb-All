//
//  BSDGPUImage.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/26/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGPUImage.h"
#import "GPUImage.h"
#import <objc/runtime.h>

@interface BSDGPUImage ()

@property (nonatomic,strong)NSDictionary *filterDictionary;
@property (nonatomic,strong)UIImage *sourceImage;
@property (nonatomic,strong)GPUImageFilter *myFilter;
@property (nonatomic,strong)NSString *prevFilterKey;

@end

@implementation BSDGPUImage

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"image filter";
    self.rightOutlet = [[BSDOutlet alloc]init];
    self.rightOutlet.name = @"right";
    [self addPort:self.rightOutlet];
    self.filterDictionary = [self getFilters];
    
    if (arguments == nil) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[@"filter"] = @"sepia";
        self.coldInlet.value = dictionary;
        return;
    }
    
    if (arguments && [arguments isKindOfClass:[NSString class]]) {
        self.name = @"image filter";
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[@"filter"] = arguments;
        self.coldInlet.value = dictionary;
        return;
    }
    
    if (arguments && [arguments isKindOfClass:[NSDictionary class]]) {
        self.coldInlet.value = [arguments mutableCopy];
        return;
    }
    
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    if (!hot || ![hot isKindOfClass:[UIImage class]]) {
        return;
    }
    UIImage *inputImage = hot;

    id cold = self.coldInlet.value;
    if (![cold isKindOfClass:[NSDictionary class]]){
        return;
    }
    
    NSMutableDictionary *parms = [self.coldInlet.value mutableCopy];
    if (![parms.allKeys containsObject:@"filter"] && !self.prevFilterKey) {
        return;
    }
    
    self.hotInlet.open = NO;
    if (![parms.allKeys containsObject:@"filter"]) {
        parms[@"filter"] = self.prevFilterKey;
    }
    
    NSString *filterName = parms[@"filter"];
    if (!self.prevFilterKey || ![filterName isEqualToString:self.prevFilterKey]) {
        self.myFilter = [self filterWithParameters:parms];
    }else {
        [parms removeObjectForKey:@"filter"];
        [self updateFilter:self.myFilter withParameters:parms];
    }
    
    __weak BSDGPUImage *weakself = self;
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        __block UIImage *output = nil;
        dispatch_sync(concurrentQueue, ^{
            output = [weakself.myFilter imageByFilteringImage:inputImage];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.mainOutlet output:output];
                weakself.prevFilterKey = filterName;
                weakself.hotInlet.open = YES;
        });
    });
    
}

- (GPUImageFilter *)filterWithName:(NSString *)filterName
{
    if (!self.filterDictionary || ![self.filterDictionary.allKeys containsObject:filterName]) {
        return nil;
    }
    
    NSString *classString = self.filterDictionary[filterName];
    Class c = NSClassFromString(classString);
    GPUImageFilter *result = [[c alloc]init];
    return result;
}

- (GPUImageFilter *)filterWithParameters:(NSDictionary *)parameters
{
    if (![parameters.allKeys containsObject:@"filter"]) {
        return nil;
    }
    NSString *filterName = parameters[@"filter"];
    id filter = [self filterWithName:filterName];
    NSMutableDictionary *parms = parameters.mutableCopy;
    [parms removeObjectForKey:@"filter"];
    if (parms.allKeys.count) {
        
        for (NSString *aKey in parms.allKeys) {
            id newValue = parms[aKey];
            [filter setValue:newValue forKey:aKey];
        }
    }
    
    return filter;
}

- (void)updateFilter:(id)filter withParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *parms = parameters.mutableCopy;
    if ([parms.allKeys containsObject:@"filter"]) {
        [parms removeObjectForKey:@"filter"];
    }
    
    if (parms.allKeys.count) {
        
        for (NSString *aKey in parms.allKeys) {
            id newValue = parms[aKey];
            [filter setValue:newValue forKey:aKey];
        }
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        if ([inlet.value isKindOfClass:[UIImage class]]){
            [self calculateOutput];
            return;
        }
        
        if ([inlet.value isKindOfClass:[NSString class]]) {
            NSString *hot = [NSString stringWithString:self.hotInlet.value];
            if ([[hot lowercaseString] isEqualToString:@"filters"]) {
                [self printFilterList];
            }
        }
    }
}



- (void)printFilterList
{
    NSMutableArray *list = self.filterDictionary.allKeys.mutableCopy;
    NSArray *orderedList = [list sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSDictionary *toPrint = @{@"filters":orderedList.mutableCopy,
                              @"parameters":self.filterDictionary[@"parameters"]};
    [self.rightOutlet output:toPrint];
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

- (NSArray *)propertyListForClassName:(NSString *)className
{
    NSMutableArray *result = nil;
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(NSClassFromString(className), &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (!result) {
            result = [NSMutableArray array];
        }
        [result addObject:key];
    }
    
    if (properties) {
        free(properties);
    }
    
    return result;
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

- (NSDictionary*) propertiesForObject:(id)obj
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    @autoreleasepool {
        
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char * aname=property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:aname];
            NSString *propertyType = [self propertyType:propertyName onObject:obj];
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
