//
//  BbObj.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "NSString+Bb.h"
#import "NSObject+Bb.h"
#import "NSInvocation+Bb.h"
#import <objc/runtime.h>
#import "BbObject+Tests.h"
#import "BbObject+EntityParent.h"
#import "NSMutableString+Bb.h"

#pragma mark - BbObject implementation

@interface BbObject (Private)


@end

@implementation BbObject

#pragma public methods
#pragma constructors

- (instancetype)initWithArguments:(id)arguments
{
    self = [super init];
    if (self) {
        [self setupWithArguments:arguments];
        if (arguments) {
            _creationArguments = [arguments copy];
        }
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupWithArguments:nil];
    }
    
    return self;
}

- (void)setupWithArguments:(id)arguments {

    [self commonInitArgs:arguments];
}

- (void)commonInitArgs:(id)args
{
    [self commonInit];
    if (args) {
        NSSet *types = [self allowedTypesForPort:self.inlets_[1]];
        BbValueType argType = [[args copy] BbValueType];
        if (types && ![types containsObject:@(argType)]) {
            [self.inlets_[1] input:[args convertToCompatibleTypeFromSet:types]];
        }else{
            [self.inlets_[1] input:args];
        }
    }
}

- (void)commonInit
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbInlet newColdInletNamed:kBbPortDefaultNameForColdInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
}

#pragma mark - accessors

- (BbInlet *)hotInlet
{
    if (self.inlets_ && self.inlets_.count > 0) {
        return self.inlets_.firstObject;
    }
    
    return nil;
}

- (BbInlet *)coldInlet
{
    if (self.inlets_ && self.inlets_.count > 1) {
        return self.inlets_[1];
    }
    
    return nil;
}

- (BbOutlet *)mainOutlet
{
    if (self.outlets_ && self.outlets_.count > 0) {
        return self.outlets_.firstObject;
    }
    
    return nil;
}

- (NSArray *)inlets
{
    if (self.inlets_ && self.inlets_.count > 0) {
        return [NSArray arrayWithArray:self.inlets_];
    }
    
    return nil;
}

- (NSArray *)outlets
{
    if (self.outlets_ && self.outlets_.count > 0) {
        return [NSArray arrayWithArray:self.outlets_];
    }
    
    return nil;
}


#pragma calculate output

- (id) outputForOutlet:(BbOutlet *)outlet withChangeInHotInlet:(BbInlet *)hotInlet
{
    NSInteger index = outlet.index;
    id hot = [hotInlet getValue];
    BbCalculateOutputBlock calculateOutputBlock = [self calculateOutputForOutletAtIndex:index];
    return calculateOutputBlock(hot,self.inlets);
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    BbCalculateOutputBlock result;
    switch (index) {
        default:
            result = ^(id hotValue, NSArray *inlets){
                return hotValue;
            };
            break;
    }
    
    return result;
}

- (NSUInteger)countAncestors
{
    if (self.parent != nil) {
        return ([self.parent countAncestors]+1);
    }else{
        return 0;
    }
}

- (BOOL)hasUI
{
    return (self.view != nil);
}

- (BOOL)wantsUI
{
    return [self.parent hasUI];
}

- (BOOL)needsUI
{
    return (![self hasUI] && [self wantsUI]);
}

- (NSArray *)UIPosition
{
    if (![self hasUI]) {
        return @[@(50),@(50)];
    }else{
        return @[@([self.view normalizedPosition].x),@([self.view normalizedPosition].y)];
    }
}

- (NSArray *)UISize
{
    return nil;
}

- (NSString *)textDescription
{
    NSMutableString *myDescription = [NSMutableString
                                      descBbObject:NSStringFromClass([self class])
                                      ancestors:[self countAncestors]
                                      position:[self UIPosition]
                                      size:[self UISize]
                                      args:[self creationArguments]];
    
    if (self.childObjects_ && self.childObjects_.count) {
        
        for (BbObject *child in [self.childObjects_ array]) {
            
            [myDescription appendObject:[child textDescription]];
        }
    }
    
    return myDescription;
}

+ (NSString *)UIType
{
    return @"obj";
}

+ (NSString *)stackInstruction
{
    return @"#X";
}

#pragma ports

- (void)addPort:(BbPort *)port
{
    if ([port isKindOfClass:[BbInlet class]]) {
        [self addInlet:(BbInlet *)port];
    }else{
        [self addOutlet:(BbOutlet *)port];
    }
}

- (void)addInlet:(BbInlet *)inlet
{
    if (!inlet || (self.inlets_ && [self.inlets_ containsObject:inlet])) {
        return;
    }
    
    inlet.parent = self;
    
    if (inlet.isHot) {
        [self observeInlet:inlet];
    }
    
    if (!self.inlets_) {
        self.inlets_ = [NSMutableArray array];
    }
    
    [self.inlets_ addObject:inlet];
    
}

- (void)addOutlet:(BbOutlet *)outlet
{
    if (!outlet || (self.outlets_ && [self.outlets_ containsObject:outlet])) {
        return;
    }
    
    outlet.parent = self;
    
    if (!self.outlets_) {
        self.outlets_ = [NSMutableArray array];
    }
    [self.outlets_ addObject:outlet];
}

- (void)observeInlet:(BbInlet *)inlet
{
    if (inlet.observers && [inlet.observers containsObject:self]) {
        return;
    }
    
    NSMutableArray *observersCopy = nil;
    if (!inlet.observers) {
        observersCopy = [NSMutableArray array];
    }else{
        observersCopy = inlet.observers.mutableCopy;
    }
    
    [inlet addObserver:self forKeyPath:kPortObservationKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [observersCopy addObject:self];
    inlet.observers = observersCopy;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil && [object isKindOfClass:[BbInlet class]]) {
        if (self.outlets_) {
            NSArray *outlets = [self.outlets_ reverseObjectEnumerator].allObjects;
            for (BbOutlet *outlet in outlets) {
                id outputValue = [self outputForOutlet:outlet withChangeInHotInlet:object];
                if (outputValue) {
                    [outlet output:[outputValue copy]];
                    if (outlet.outputBlock != NULL) {
                        outlet.outputBlock([outputValue copy]);
                    }
                }
            }
            
        }else{
            [self outputForOutlet:nil withChangeInHotInlet:object];
        }

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tearDown
{
    [super tearDown];
    
    for (BbInlet *inlet in self.inlets_) {
        [inlet tearDown];
    }
    
    for (BbOutlet *outlet in self.outlets_) {
        [outlet tearDown];
    }
    
    for (BbObject *childObject in [self.childObjects_ array]) {
        [self removeChildObject:childObject];
        [childObject tearDown];
    }
    
    self.childObjects_ = nil;
    self.childObjects = nil;
    
    self.outlets_ = nil;
    self.parent = nil;
    self.view = nil;
}

- (void)dealloc
{
    [self tearDown];
}


@end

