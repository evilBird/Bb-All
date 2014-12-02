//
//  BSDPointer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/11/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMethod.h"
#import <objc/runtime.h>

@implementation BSDMethod

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"method";
    
    self.selectorInlet = [[BSDStringInlet alloc]initCold];
    self.selectorInlet.name = @"selector";
    [self addPort:self.selectorInlet];
    
    self.argumentsInlet = [[BSDArrayInlet alloc]initCold];
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
    id pointer = self.coldInlet.value;
    NSString *selectorName = self.selectorInlet.value;
    NSArray *arguments = self.argumentsInlet.value;
    
    if (!pointer || !selectorName) {
        return;
    }
    
    id output = [self doSelectorWithPointer:pointer selectorName:[NSString stringWithString:selectorName] arguments:[NSMutableArray arrayWithArray:arguments]];
    
    if (output) {
        [self.mainOutlet output:output];
    }else{
        [self.mainOutlet output:[BSDBang bang]];
    }
    
    self.coldInlet.value = nil;
}

- (id)doSelectorWithPointer:(id)pointer selectorName:(NSString *)selectorName arguments:(NSArray *)arguments
{
    SEL aSelector = NSSelectorFromString(selectorName);
    if (![pointer respondsToSelector:aSelector]) {
        NSString *className = NSStringFromClass([pointer class]);
        return [NSString stringWithFormat:@"\nBSDPointer ERROR:\nClass %@ does respond to selector %@\n",className,selectorName];
    }
    const char *class = [NSStringFromClass([pointer class]) UTF8String];
    id c = objc_getClass(class);
    NSMethodSignature *methodSig = [c instanceMethodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    [invocation setTarget:pointer];
    [invocation setSelector:aSelector];
    if (arguments) {
        
        for (NSInteger idx = 0; idx < arguments.count; idx++) {
            id arg = arguments[idx];
            NSInteger maxIdx = [methodSig numberOfArguments];
            NSInteger argIdx = idx + 2;
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
    NSLog(@"return type: %@",returnType);
    if (![returnType isEqualToString:@"v"]) {
        [invocation getReturnValue:&result];
    }
    return result;
}



@end
