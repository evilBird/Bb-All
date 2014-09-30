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
        self.classNameInlet.value = @"UIView";
    }
    [self addPort:self.classNameInlet];
    
    self.selectorInlet = [[BSDStringInlet alloc]initCold];
    self.selectorInlet.name = @"selector";
    self.selectorInlet.value = @"initWithFrame:";
    [self addPort:self.selectorInlet];
    
    self.creationArgsInlet = [[BSDInlet alloc]initCold];
    self.creationArgsInlet.name = @"creation args";
    self.creationArgsInlet.value = [NSValue wrapRect:CGRectMake(0, 0, 44, 44)];
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
        [invocation setArgument:&creationArgs atIndex:2];
    }
    
    [invocation invoke];
    return instance;
}


@end
