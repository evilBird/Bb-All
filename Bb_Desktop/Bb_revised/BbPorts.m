//
//  BbPorts.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPorts.h"

#pragma mark - BbPortElement Implementation

@implementation BbPortElement

- (instancetype)initWithScope:(PortElementScope)scope
{
    self = [super init];
    if (self) {
        _scope = scope;
        if (scope == PortElementScopeInput) {
            self.name = @"in";
        }else{
            self.name = @"out";
        }
    }
    
    return self;
}

- (void)setValue:(id)value
{
    _value = value;
    if (self.scope == PortElementScopeInput){
        
    }
}

- (void)observePortElement:(BbPortElement *)element
{
    if (element.scope == PortElementScopeInput) {
        [self observeInputElement:element];
    }else{
        [self observeOutputElement:element];
    }
}

- (void)observeInputElement:(BbPortElement *)inputElement {}

- (void)observeOutputElement:(BbPortElement *)outputElement
{
    if (outputElement.observers && [outputElement.observers containsObject:self]) {
        return;
    }
    
    NSMutableArray *observersCopy = nil;
    if (!outputElement.observers) {
        observersCopy = [NSMutableArray array];
    }else{
        observersCopy = outputElement.observers.mutableCopy;
    }
    
    [outputElement addObserver:self forKeyPath:kPortElementObservationKey options:NSKeyValueObservingOptionNew context:nil];
    [observersCopy addObject:outputElement];
    outputElement.observers = observersCopy;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil && [object isKindOfClass:[BbPortElement class]]) {
        PortElementScope scope = [(BbPortElement *)object scope];
        if (scope == PortElementScopeOutput) {
            self.value = [object valueForKeyPath:kPortElementObservationKey];
        }else{
            
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tearDown
{
    [super tearDown];
    
    if (self.observers) {
        for (id observer in self.observers) {
            [self removeObserver:observer forKeyPath:kPortElementObservationKey];
        }
    }
    self.observers = nil;
    self.value = nil;
}

@end


#pragma mark - BbPort Implementation

@interface BbPort ()

@property (nonatomic,strong)NSSet *allowedTypes;

@end

@implementation BbPort

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureElements];
    }
    
    return self;
}

- (void)configureElements
{
    self.inputElement = [[BbPortElement alloc]initWithScope:PortElementScopeInput];
    self.inputElement.parent = self;
    self.outputElement = [[BbPortElement alloc]initWithScope:PortElementScopeOutput];
    self.outputElement.parent = self;
    [self.inputElement addObserver:self forKeyPath:kPortElementObservationKey options:NSKeyValueObservingOptionNew context:nil];
    self.inputElement.observers = [NSMutableArray arrayWithObject:self];
}

- (id)getValue
{
    id value = [self valueForKeyPath:kPortObservationKeyPath];
    return value;
}

- (id)outputForInputValue:(id)input
{
    BbValidateTypeBlock validateTypeBlock = [self getValidateTypeBlock];
    return validateTypeBlock(input);
}

- (BbValidateTypeBlock)getValidateTypeBlock
{
    if (!self.allowedTypes) {
        self.allowedTypes = [[self.parent allowedTypesForPort:self]copy];
    }
    __weak BbPort *weakself = self;
    BbValidateTypeBlock result = ^(id value){
        
        if (!weakself.allowedTypes) {
            return [value copy];
        }else if ([weakself.allowedTypes containsObject:@([[value copy] BbValueType])]){
            return [value copy];
        }
        id convertedValue = [[value copy] convertToCompatibleTypeFromSet:weakself.allowedTypes];
        return convertedValue;
    };
    
    return result;
}

- (NSInteger)index
{
    return [self.parent indexOfPort:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        if (object == self.inputElement) {
            self.outputElement.value = [self outputForInputValue:[[object valueForKeyPath:keyPath]copy]];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tearDown
{
    [super tearDown];
    
    [self.inputElement tearDown];
    [self.outputElement tearDown];
    
    if (self.observers) {
        for (id observer in self.observers) {
            [self removeObserver:observer forKeyPath:kPortObservationKeyPath];
        }
    }
    
    self.observers = nil;
}

@end

#pragma mark - BbInlet Implementation

@implementation BbInlet

+ (BbInlet *)newHotInletNamed:(NSString *)name
{
    BbInlet *inlet = [[BbInlet alloc]init];
    inlet.name = name;
    inlet.hot = YES;
    return inlet;
}

+ (BbInlet *)newColdInletNamed:(NSString *)name
{
    BbInlet *inlet = [[BbInlet alloc]init];
    inlet.name = name;
    return inlet;
}

- (void)input:(id)value
{
    if ([value isKindOfClass:[BbBang class]]) {
        [self.parent hotInlet:self receivedBang:value];
    }else{
        self.inputElement.value = value;
    }
}

@end

#pragma mark - BbOutlet Implementation

@implementation BbOutlet

+ (BbOutlet *)newOutletNamed:(NSString *)name
{
    BbOutlet *outlet = [[BbOutlet alloc]init];
    outlet.name = name;
    return outlet;
}


- (BOOL)canConnectToInlet:(BbInlet *)inlet
{
    return YES;
}

- (void)connectToInlet:(BbInlet *)inlet
{
    if (!inlet || ![self canConnectToInlet:inlet]) {
        //Error
        return;
    }
    
    [inlet.inputElement observePortElement:self.outputElement];
}

- (void)disconnectFromInlet:(BbInlet *)inlet
{
    [self.outputElement removeObserver:inlet.inputElement forKeyPath:kPortElementObservationKey];
    [self.outputElement.observers removeObject:inlet.inputElement];
}

- (void)output:(id)value
{
    self.inputElement.value = value;
}


@end
