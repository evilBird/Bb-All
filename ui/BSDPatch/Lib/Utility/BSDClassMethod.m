//
//  BSDClassMethod.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDClassMethod.h"
#import "NSObject+ObjC.h"
#import "NSInvocation+Bb.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>

@interface BSDClassMethod()

@property (nonatomic,strong)id returnVal;

@end


@implementation BSDClassMethod
- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"cls method";
    
    self.selectorInlet = [[BSDInlet alloc]initCold];
    self.selectorInlet.name = @"selector";
    [self addPort:self.selectorInlet];
    
    self.argumentsInlet = [[BSDInlet alloc]initCold];
    self.argumentsInlet.name = @"arguments";
    [self addPort:self.argumentsInlet];
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSString *className = self.coldInlet.value;
    NSString *selectorName = self.selectorInlet.value;
    NSArray *arguments = self.argumentsInlet.value;
    
    if ( nil == className || nil == selectorName  )  {
        return;
    }
    
    id output = nil;
    
    if ( nil != arguments ) {
        if ( ![arguments isKindOfClass:[NSArray class]] ) {
            id arg = self.argumentsInlet.value;
            arguments = @[arg];
        }
    }
    
    output = [NSInvocation doClassMethod:className selectorName:selectorName args:arguments];
    
    if (nil != output) {
        [self.mainOutlet output:output];
    }else{
        [self.mainOutlet output:[BSDBang bang]];
    }
    
}
/*
- (id)doSelectorWithClassName:(NSString *)className selectorName:(NSString *)selectorName arguments:(NSArray *)arguments
{
    SEL aSelector = NSSelectorFromString(selectorName);
    Class myClass = NSClassFromString(className);
    if (![myClass respondsToSelector:aSelector]) {
        return [NSString stringWithFormat:@"\nBSDPointer ERROR:\nClass %@ does respond to selector %@\n",className,selectorName];
    }

    NSMethodSignature *methodSig = [myClass methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [invocation setTarget:myClass];
    [invocation setSelector:aSelector];
    if (arguments) {
        
        for (NSInteger idx = 0; idx < arguments.count; idx++) {
            id arg = arguments[idx];
            [invocation setArgumentWithObject:arg atIndex:idx];
            //NSInteger maxIdx = [methodSig numberOfArguments];
            
            //NSInteger argIdx = idx + 2;
            /*
            if (argIdx < maxIdx) {
                NSString *argType = [NSString stringWithUTF8String:[methodSig getArgumentTypeAtIndex:argIdx]];
                NSLog(@"arg type: %@",argType);
                if ([argType isEqualToString:@"i"]) {
                    int a = [arg intValue];
                    [invocation setArgument:&a atIndex:(2+idx)];
                }else if ([argType isEqualToString:@"d"]) {
                    double a = [arg doubleValue];
                    [invocation setArgument:&a atIndex:(2+idx)];
                }else if ([argType isEqualToString:@"f"]) {
                    double a = [arg floatValue];
                    [invocation setArgument:&a atIndex:(2+idx)];
                }else if ([argType isEqualToString:@"@"]){
                    [invocation setArgument:&arg atIndex:(2+idx)];
                }else if ([argType isEqualToString:@"Q"]){
                    NSInteger a = [arg integerValue];
                    [invocation setArgument:&a atIndex:(2+idx)];
                }
            }
        }
    }
    
    id result = nil;
    [invocation invoke];
    NSString *returnType = [NSString stringWithUTF8String:[methodSig methodReturnType]];
    if (![returnType isEqualToString:@"v"] && [returnType isEqualToString:@"@"]) {
        void *returnVal = nil;
        [invocation getReturnValue:&returnVal];
        result = [(__bridge NSObject *)returnVal copy];
        //free(returnVal);
    }
    
    return result;
}


*/
@end
