//
//  BSDPointer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/11/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPointer.h"
#import <objc/runtime.h>

@implementation BSDPointer

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"pointer";
    
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
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    [invocation setTarget:pointer];
    [invocation setSelector:aSelector];
    if (arguments) {
        
        for (NSInteger idx = 0; idx < arguments.count; idx++) {
            id arg = arguments[idx];
            [invocation setArgument:&arg atIndex:(2+idx)];
        }
    }
    
    void* result = malloc([[c methodSignatureForSelector:aSelector] methodReturnLength]);
    [invocation invoke];
    [invocation getReturnValue:&result];
    return (__bridge id)(result);
}



@end
