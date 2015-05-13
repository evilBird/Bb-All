//
//  BSDLayer.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLayer.h"
#import <objc/runtime.h>

@interface BSDLayer ()

@property (nonatomic,strong)NSMutableDictionary *setterDictionary;

@end

@implementation BSDLayer

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [self displayName];
    
    self.layerInlet = [[BSDInlet alloc]initHot];
    self.layerInlet.name = @"layer inlet";
    self.layerInlet.delegate = self;
    [self addPort:self.layerInlet];
    
    self.animationInlet = [[BSDInlet alloc]initHot];
    self.animationInlet.name = @"animation inlet";
    [self addPort:self.animationInlet];
    
    self.selectorInlet = [[BSDInlet alloc]initHot];
    self.selectorInlet.name = @"selector inlet";
    [self addPort:self.selectorInlet];
    
    self.setterInlet = [[BSDInlet alloc]initHot];
    self.setterInlet.name = @"setter inlet";
    [self addPort:self.setterInlet];
    
    self.getterInlet = [[BSDInlet alloc]initHot];
    self.getterInlet.name = @"getter inlet";
    [self addPort:self.getterInlet];
    
    self.getterOutlet = [[BSDOutlet alloc]init];
    self.getterOutlet.name = @"getter outlet";
    [self addPort:self.getterOutlet];
    
    NSArray *frameArr = arguments;
    CGRect frame = CGRectMake(0, 0, 44, 44);
    if (frameArr && [frameArr isKindOfClass:[NSArray class]] && frameArr.count == 4) {
        frame.origin.x = [arguments[0] doubleValue];
        frame.origin.y = [arguments[1] doubleValue];
        frame.size.width = [arguments[2] doubleValue];
        frame.size.height = [arguments[3] doubleValue];
        id myLayer = [self makeMyLayerWithFrame:frame];
        self.layerInlet.value = myLayer;
    }
}


- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.layerInlet) {
        CALayer *myLayer = [self layer];
        if (myLayer == nil) {
            myLayer = [self makeMyLayer];
            self.layerInlet.value = myLayer;
        }
        [self.mainOutlet output:myLayer];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.layerInlet) {
        [self updateLayer];
        [self.mainOutlet output:[self layer]];
    }else if (inlet == self.setterInlet){
        [self updateLayer];
    }else if (inlet == self.animationInlet){
        [self doAnimation];
    }else if (inlet == self.selectorInlet){
        [self doSelector];
    }else if (inlet == self.getterInlet){
        
    }
}

- (void)updateLayer
{
    id hot = self.setterInlet.value;
    id layer = self.layerInlet.value;
    if (!hot || !layer || ![layer isKindOfClass:[CALayer class]] || ![hot isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSMutableDictionary *setters = [(NSDictionary *)hot mutableCopy];
    NSDictionary *properties = [self propertiesForObject:layer];
    
    for (id aKey in setters.allKeys) {
        id aVal = setters[aKey];
        if ([properties.allKeys containsObject:aKey]) {
            if ([aVal isKindOfClass:[UIColor class]]) {
                [layer setValue:(id)[aVal CGColor] forKey:aKey];
            }else if ([aVal isKindOfClass:[UIBezierPath class]]){
                [layer setValue:(id)[aVal CGPath] forKey:aKey];
            }else{
                [layer setValue:aVal forKey:aKey];
            }
        }else{
            NSLog(@"layer does not have property %@",aKey);
        }
    }
    
    [layer setNeedsDisplay];
}

- (void)doAnimation
{
    id a = self.animationInlet.value;
    if (a == nil) {
        return;
    }
    
    if ([a isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *animation = self.animationInlet.value;
        CALayer *layer = [self layer];
        [layer addAnimation:animation forKey:animation.keyPath];
        [layer setValue:animation.toValue forKey:animation.keyPath];
    }else if ([a isKindOfClass:[CAKeyframeAnimation class]]){
        CAKeyframeAnimation *animation = self.animationInlet.value;
        CALayer *layer = [self layer];
        [layer addAnimation:animation forKey:animation.keyPath];
        [layer setValue:animation.values.lastObject forKey:animation.keyPath];
    }
}

- (void)doSelectorWithArray:(NSArray *)array
{
    if (!array || array.count == 0) {
        return;
    }
    
    NSMutableArray *copy = array.mutableCopy;
    id first = copy.firstObject;
    if (![first isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSString *selectorName = [NSString stringWithString:first];
    NSArray *args = nil;
    if (copy.count > 1) {
        [copy removeObject:first];
        args = [NSArray arrayWithArray:copy];
    }
    
    SEL selector = NSSelectorFromString(selectorName);
    CALayer *myLayer = [self layer];
    
    if (!myLayer) {
        return;
    }
    
    Class c = [myLayer class];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:selector]];
    invocation.target = myLayer;
    invocation.selector = selector;
    
    if (args != nil) {
        for (NSUInteger idx = 0; idx < args.count; idx ++) {
            NSInteger argIdx = 2+idx;
            id myArg = args[idx];
            [invocation setArgument:&myArg atIndex:argIdx];
        }
    }
    
    if ([myLayer respondsToSelector:selector]) {
        [invocation invoke];
    }
    
    
}

- (void)doSelector
{
    id val = self.selectorInlet.value;
    
    if (val == nil) {
        return;
    }
    
    if ([val isKindOfClass:[NSArray class]]) {
        [self doSelectorWithArray:val];
        return;
    }
    
    if ([val isKindOfClass:[NSString class]]) {
        NSArray *arr = @[val];
        [self doSelectorWithArray:arr];
        return;
    }
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = val;
        NSArray *arr = @[dict.allKeys.firstObject,dict.allValues.firstObject];
        [self doSelectorWithArray:arr];
        return;
    }
}

- (NSString *)displayName
{
    return @"layer";
}

- (CALayer *)layer
{
    return self.layerInlet.value;
}

- (CALayer *)makeMyLayer
{
    return [self makeMyLayerWithFrame:CGRectMake(0, 0, 44, 44)];
}
- (CALayer *)makeMyLayerWithFrame:(CGRect)frame
{
    CALayer *layer = [[CALayer alloc]init];
    layer.frame = frame;
    return layer;
}

- (NSArray *)properties:(id)obj
{
    NSMutableArray *result = nil;
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
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

- (NSDictionary *)mapLayer:(CALayer *)layer
{
    return [self mapObject:layer];
}

- (NSDictionary *)mapObject:(id)obj
{
    NSMutableArray *properties = [self properties:obj].mutableCopy;
    NSString *badKey = @"unsatisfiableConstraintsLoggingSuspended";
    if ([properties containsObject:badKey]) {
        [properties removeObject:badKey];
    }
    
    return [obj dictionaryWithValuesForKeys:properties];
}

@end
