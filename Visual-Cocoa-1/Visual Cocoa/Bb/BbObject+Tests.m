//
//  BbObject+Tests.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+Tests.h"
#import <objc/runtime.h>

@implementation BbObject (Tests)

- (NSString *)className
{
    return NSStringFromClass([self class]);
}


- (NSArray *)testCases
{
    return nil;
}

- (NSString *)testFailedMessageFormatValue:(id)value index:(NSInteger)index caseNumber:(NSInteger)caseNumber
{
    id output = [self.outlets[index]getValue];
    NSString *result = [NSString stringWithFormat:@"\n%@) TEST CASE FOR CLASS %@ FAILED!\nREASON: inlet %@ = %@ (should equal %@)\n",@(caseNumber),self.className,@(index),output,value];
    
    return result;
}

- (NSString *)testPassedMessageCaseNumber:(NSInteger)caseNumber
{
    NSString *result = [NSString stringWithFormat:@"\n%@) TEST CASE FOR CLASS %@ PASSED\n",@(caseNumber),self.className];
    return result;
}

+ (NSArray *)testCasesForClassName:(NSString *)className
{
    const char *class = [className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL selector = NSSelectorFromString(@"testCases");
    
    NSMethodSignature *methodSig = [c instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    invocation.target = instance;
    invocation.selector = selector;
    NSArray *result = nil;
    [invocation invoke];
    NSString *returnType = [NSString stringWithUTF8String:[methodSig methodReturnType]];
    if ([returnType isEqualToString:@"@"]) {
        void *returnVal = nil;
        [invocation getReturnValue:&returnVal];
        result = (__bridge NSArray *)returnVal;
    }
    
    return result;
}


@end

