//
//  BbObject+Decoder.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+Decoder.h"
#import "BbParsers.h"
#import <Objc/runtime.h>
#import "NSInvocation+Bb.h"
#import "BbConstants.h"
#import "BbBasicMath.h"

@implementation BbObject (Decoder)

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description
{
    BbObject *object = nil;
    object = [BbObject newObjectClassName:description.BbObjectType arguments:description.BbObjectArgs];
    return object;
}

+ (BbObject *)objectFromText:(NSString *)text
{
    BbObjectDescription *desc = (BbObjectDescription *)[BbBasicParser descriptionWithText:text];
    return [BbObject objectWithDescription:desc];
}

+ (instancetype)newObjectClassName:(NSString *)className arguments:(id)arguments
{
    const char *class = [className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL initializer;
    if (arguments) {
        initializer = NSSelectorFromString(kBbObjectArgIntializer);
    }else{
        initializer = NSSelectorFromString(kBbObjectDefaultInitializer);
    }
    
    NSMethodSignature *methodSig = [instance methodSignatureForSelector:initializer];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    invocation.target = instance;
    invocation.selector = initializer;
    if (arguments){
        [invocation setArgumentWithObject:arguments atIndex:0];
    }
    
    id result = nil;
    [invocation invoke];
    NSString *returnType = [NSString stringWithUTF8String:[methodSig methodReturnType]];
    if ([returnType isEqualToString:@"@"]) {
        void *returnVal = nil;
        [invocation getReturnValue:&returnVal];
        result = (__bridge NSObject *)returnVal;
    }
    
    return result;
}

@end
