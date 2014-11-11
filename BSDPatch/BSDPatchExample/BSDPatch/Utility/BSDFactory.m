//
//  BSDFactory.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/26/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDFactory.h"
#import "BSDStringInlet.h"
#import "NSValue+BSD.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface BSDFactory ()

@property (nonatomic,strong)id myInstance;

@end

@implementation BSDFactory

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"factory";
    
    self.classNameInlet = [[BSDStringInlet alloc]initCold];
    self.classNameInlet.name = @"class name";
    
    NSString *className = arguments;
    if (className && [className isKindOfClass:[NSString class]]) {
        self.classNameInlet.value = className;
    }else{
        self.classNameInlet.value = nil;
    }
    
    [self addPort:self.classNameInlet];
    
    self.selectorInlet = [[BSDStringInlet alloc]initCold];
    self.selectorInlet.name = @"selector";
    self.selectorInlet.value = nil;
    [self addPort:self.selectorInlet];
    
    self.creationArgsInlet = [[BSDInlet alloc]initCold];
    self.creationArgsInlet.name = @"creation args";
    self.creationArgsInlet.value = nil;
    [self addPort:self.creationArgsInlet];
    
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    id instance = [self makeInstance];
    if (instance) {
        [self.mainOutlet output:instance];
    }
}

- (id)makeInstance
{
    NSString *className = self.classNameInlet.value;
    NSString *selectorName = self.selectorInlet.value;
    id creationArgs = self.creationArgsInlet.value;
    
    if (!className || !selectorName) {
        return nil;
    }
    
    const char *class = [className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    self.myInstance = nil;
    self.myInstance = instance;
    SEL aSelector = NSSelectorFromString(selectorName);
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    
    if (creationArgs != nil) {
        if ([creationArgs isKindOfClass:[NSArray class]]) {
            NSArray *args = creationArgs;
            for (NSInteger i = 0; i < args.count; i++) {
                id arg = args[i];
                NSInteger argIdx = i + 2;
                if ([arg isKindOfClass:[NSValue class]]) {
                    NSValue *val = arg;
                    [invocation setArgument:&val atIndex:argIdx];
                }else{
                    [invocation setArgument:&arg atIndex:argIdx];
                }
            }
        }else{
            if ([creationArgs isKindOfClass:[NSValue class]]) {
                NSValue *val = creationArgs;
                [invocation setArgument:&val atIndex:2];
            }else{
                [invocation setArgument:&creationArgs atIndex:2];
            }
        }
    }
    
    [invocation invoke];
    return instance;
}


@end
