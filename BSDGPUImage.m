//
//  BSDGPUImage.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/26/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGPUImage.h"
#import "BSDObjects.h"


@interface BSDGPUImage ()

@property (nonatomic,strong)NSDictionary *filterDictionary;
@property (nonatomic,strong)UIImage *sourceImage;

@property (nonatomic,strong)GPUImageView *imageView;

@property (nonatomic)BOOL ready;

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
    self.parameterInlet = [[BSDInlet alloc]initCold];
    self.parameterInlet.name = @"parameters";
    self.parameterInlet.delegate = self;
    [self addPort:self.parameterInlet];
    
    if (arguments == nil) {
        self.coldInlet.value = @"sepia";
        return;
    }
    
    if (arguments && [arguments isKindOfClass:[NSString class]]) {
        self.coldInlet.value = arguments;
        return;
    }
    
    self.ready = YES;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self hotInlet:inlet receivedValue:self.previousImage];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        if ([value isKindOfClass:[NSString class]] && [[value lowercaseString]isEqualToString:@"filters"]) {
                [self printFilterList];
                return;
        }
        if (!self.ready) {
            //return;
        }
        
        self.ready = NO;
        //Handle the image input
        UIImage *sourceImage = nil;
        //If the image is new, we will create a new GPUImagePicture instance
        BOOL imageIsNew = NO;
        static UIImage *prevImage;
        //validate input. if valid, assign to sourceImage var
        if (!value || ![value isKindOfClass:[UIImage class]]) {
            //try to use prev image
            if (prevImage && [prevImage isKindOfClass:[UIImage class]]) {
                sourceImage = prevImage;
                imageIsNew = NO;
            }
        }else{
            //if there is no previous image or the new value is not the same as the previous image, we update the imageIsNew var
            if (!prevImage || value != prevImage) {
                imageIsNew = YES;
            }
            sourceImage = value;
        }
        
        //If the source image is nil at this point, we bail
        if (!sourceImage) {
            self.ready = YES;
            return;
        }
        //If image is new, we'll set up a new pictureImage
        if (imageIsNew) {
            [self.picture removeAllTargets];
            self.picture = nil;
            self.picture = [self pictureWithImage:sourceImage];
        }
        
        //See if we need to change filter type
        NSString *filterKey = self.coldInlet.value;
        BOOL filterIsNew = NO;
        
        if (!filterKey){
            filterKey = self.prevFilterKey;
            filterIsNew = YES;
        }else if (![filterKey isEqualToString:self.prevFilterKey]){
            filterIsNew = YES;
        }else if (!self.myFilter){
            filterIsNew = YES;
        }
        
        //if the filter is new, we'll create a new one and make it the target of our picture
        if (filterIsNew) {
            [self.myFilter removeAllTargets];
            self.myFilter = nil;
            self.myFilter = [self filterWithName:filterKey];
            [self.picture addTarget:self.myFilter];
            //since we've loaded a new filter, we'll map it and send the result to the right outlet
            BSDMapObject *mapper = [[BSDMapObject alloc]init];
            NSDictionary *map = @{@"parameters":[mapper dictionaryForObject:self.myFilter]};
            [self.rightOutlet output:map];
        }else{
            //if filter is not new, we add still need to add it as a target of our picture if the image is new
            if (imageIsNew) {
                [self.picture addTarget:self.myFilter];
            }
        }
        
        prevImage = sourceImage;
        [self filterImage:sourceImage withFilterKey:filterKey];

    }
    
    
}

- (void)filterImage:(UIImage *)sourceImage withFilterKey:(NSString *)filterKey
{

    //since the filter and picture are configured, we'll force the filter to render at the size of the image
    [self.myFilter forceProcessingAtSize:sourceImage.size];
    
    NSDictionary *parms = self.parameterInlet.value;
    
    //void update filter parms as needed
    if (parms && [parms isKindOfClass:[NSDictionary class]]) {
        [self updateFilter:self.myFilter withParameters:parms];
    }
    
    //Everything should be set up, let's process the image...
    self.prevFilterKey = filterKey;
    self.previousImage = sourceImage;
    [self.myFilter useNextFrameForImageCapture];
    [self.picture processImageWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainOutlet output:[self.myFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp]];
        });
    }];
}

- (GPUImagePicture *)pictureWithImage:(UIImage *)image
{
    return [[GPUImagePicture alloc]initWithImage:image smoothlyScaleOutput:YES];
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

- (void)updateFilter:(id)filter withParameters:(NSDictionary *)parameters
{
    if (!parameters || !filter) {
        return;
    }
    
    NSMutableDictionary *parms = parameters.mutableCopy;
    BSDMapObject *mapper = [[BSDMapObject alloc]init];
    NSArray *properties = [mapper properties:filter];
    if (parms.allKeys.count) {
        
        for (NSString *aKey in parms.allKeys) {
            id newValue = parms[aKey];
            if ([properties containsObject:aKey]) {
                [filter setValue:newValue forKey:aKey];
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
        if ([[class lowercaseString] hasPrefix:@"gpuimage"] && [[class lowercaseString] hasSuffix:@"filter"] &&[[class lowercaseString]rangeOfString:@"blend"].length == 0) {
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
