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
#import "BSDObjects.h"


@interface BSDGPUImage ()

@property (nonatomic,strong)NSDictionary *filterDictionary;
@property (nonatomic,strong)UIImage *sourceImage;
@property (nonatomic,strong)GPUImagePicture *picture;
@property (nonatomic,strong)GPUImageFilter *myFilter;
@property (nonatomic,strong)GPUImageView *imageView;
@property (nonatomic,strong)UIImage *previousImage;
@property (nonatomic,strong)NSString *prevFilterKey;
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
/*
- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    if (hot && [hot isKindOfClass:[UIImage class]] && hot != self.sourceImage) {
        self.sourceImage = hot;
        self.picture = nil;
        self.picture = [[GPUImagePicture alloc]initWithImage:self.sourceImage smoothlyScaleOutput:YES];
    }
    
    UIImage *inputImage = self.sourceImage;
    if (!inputImage) {
        return;
    }
    
    
    id cold = self.coldInlet.value;
    if (cold && ![cold isKindOfClass:[NSDictionary class]]){
        return;
    }
    self.hotInlet.open = NO;
    NSMutableDictionary *parms = [self.coldInlet.value mutableCopy];
    NSString *filterName = nil;
    if ([parms.allKeys containsObject:@"filter"]) {
        filterName = [parms valueForKey:@"filter"];
        [parms removeObjectForKey:@"filter"];
        if (parms.allKeys.count == 0) {
            parms = nil;
        }
    }else{
        filterName = self.prevFilterKey;
    }
    
    if (![filterName isEqualToString:self.prevFilterKey]) {
        self.myFilter = nil;
        self.prevFilterKey = filterName;
    }
    
    if (!self.myFilter) {
        self.myFilter = [self filterWithName:filterName];
    }else{
        [self.myFilter useNextFrameForImageCapture];
    }
    
    if (parms) {
        [self updateFilter:self.myFilter withParameters:parms];
    }
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self.mainOutlet output:[self.myFilter imageByFilteringImage:inputImage]];
        self.hotInlet.open = YES;
    }];
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
     self.myFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"mandelbrot"];
     UIImage *output = [self.myFilter imageByFilteringImage:hot];
     [self.mainOutlet output:output];
}
*/

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
        
        //since the filter and picture are configured, we'll force the filter to render at the size of the image
        [self.myFilter forceProcessingAtSize:sourceImage.size];
        
        NSDictionary *parms = self.parameterInlet.value;
        
        //void update filter parms as needed
        if (parms && [parms isKindOfClass:[NSDictionary class]]) {
            [self updateFilter:self.myFilter withParameters:parms];
        }
        
        //Everything should be set up, let's process the image...
        prevImage = sourceImage;
        self.prevFilterKey = filterKey;
        self.previousImage = sourceImage;
        [self.myFilter useNextFrameForImageCapture];
        [self.picture processImageWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.mainOutlet output:self.myFilter.imageFromCurrentFramebuffer];
                [self.mainOutlet output:[self.myFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp]];

                [self setReady:YES];
            });
        }];
        
        
        
        /*
        
        BOOL newFilter = NO;
        if (!self.prevFilterKey || ![self.prevFilterKey isEqualToString:self.coldInlet.value]) {
            newFilter = YES;
        }
        
        if ([value isKindOfClass:[UIImage class]] && value != prevImage) {
            if (newFilter) {
                [self createFilterAndCalculateOutput];
            }else{
                [self filterImage];
            }
            prevImage = value;
            self.prevFilterKey = self.coldInlet.value;
        }
        
        return;
         */
    }
    /*
    if (inlet == self.parameterInlet) {
        
        BOOL newFilter = NO;
        if (!self.prevFilterKey || ![self.prevFilterKey isEqualToString:self.coldInlet.value]) {
            newFilter = YES;
        }
        
        if (newFilter) {
            [self createFilterAndCalculateOutput];
        }else{
            [self updateFilterAndCalculateOutput];
        }
        self.prevFilterKey = self.coldInlet.value;
    }
     */
}

- (void)filterImage
{
    if (!self.ready) {
        //return;
    }
    self.ready = NO;
    [self.picture removeAllTargets];
    self.picture = nil;
    self.picture = [self pictureWithImage:self.hotInlet.value];
    [self.picture addTarget:self.myFilter];
    [self.myFilter forceProcessingAtSize:self.picture.outputImageSize];
    [self.myFilter useNextFrameForImageCapture];
    [self.picture processImageWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainOutlet output:self.myFilter.imageFromCurrentFramebuffer];
            [self setReady:YES];
        });
    }];
}

- (void)createFilterAndCalculateOutput
{
    if (!self.ready) {
        //return;
    }
    id filterKey = self.coldInlet.value;
    if (!filterKey ||
        ![filterKey isKindOfClass:[NSString class]] ||
        ![self.filterDictionary.allKeys containsObject:[filterKey lowercaseString]])
    {
        return;
    }
    self.ready = NO;

    if (!self.picture) {
        self.picture = [self pictureWithImage:self.hotInlet.value];
    }
    
    [self.picture removeAllTargets];
    [self.myFilter removeAllTargets];
    self.myFilter = nil;
    self.myFilter = [self filterWithName:filterKey];
    [self.picture addTarget:self.myFilter];
    [self.myFilter forceProcessingAtSize:self.picture.outputImageSize];
    [self.myFilter useNextFrameForImageCapture];
    [self.picture processImageWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainOutlet output:self.myFilter.imageFromCurrentFramebuffer];
            [self setReady:YES];
        });
    }];
}

- (void)updateFilterAndCalculateOutput
{
    if (!self.ready) {
        //return;
    }
    self.ready = NO;
    id parms = self.parameterInlet.value;
    if (parms && [parms isKindOfClass:[NSDictionary class]]) {
        [self updateFilter:self.myFilter withParameters:parms];
    }
    [self.myFilter forceProcessingAtSize:self.picture.outputImageSize];
    [self.myFilter useNextFrameForImageCapture];
    [self.picture processImageWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainOutlet output:self.myFilter.imageFromCurrentFramebuffer];
            [self setReady:YES];
        });
    }];
}

- (GPUImagePicture *)pictureWithImage:(UIImage *)image
{
    return [[GPUImagePicture alloc]initWithImage:image smoothlyScaleOutput:YES];
}

- (GPUImageView *)imageViewForPicture:(GPUImagePicture *)picture
{
    CGRect frame = CGRectMake(0.0, 0.0, picture.outputImageSize.width, picture.outputImageSize.height);
    GPUImageView *imageView = [[GPUImageView alloc]initWithFrame:frame];
    return imageView;
}

- (void)calculateOutput
{
    /*
    id hot = self.hotInlet.value;
    static UIImage *sourceImage;
    if (hot && [hot isKindOfClass:[UIImage class]] && hot != sourceImage) {
        sourceImage = nil;
        self.picture = nil;
        sourceImage = hot;
        self.picture = [[GPUImagePicture alloc]initWithImage:sourceImage smoothlyScaleOutput:YES];
    }
    
    if (!self.picture) {
        NSLog(@"no picture");
        return;
    }
    */
    
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
/*
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

*/

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
