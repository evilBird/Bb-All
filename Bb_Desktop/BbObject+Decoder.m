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
#import "BbStandardLib.h"

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

+ (NSString *)lookUpClassWithText:(NSString *)text
{
    NSArray *libClasses = [BbObject BbStandardLibraryClassNames];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@ OR SELF BEGINSWITH[cd] %@",
                              text,[@"Bb" stringByAppendingString:text]];
    NSArray *filtered = [libClasses filteredArrayUsingPredicate:predicate];
    NSSortDescriptor *lengthSort = [NSSortDescriptor sortDescriptorWithKey:@"length" ascending:YES];
    NSArray *sorted = [filtered sortedArrayUsingDescriptors:@[lengthSort]];
    NSString *first = sorted.firstObject;
    return first;
}

+ (NSArray *)listClassesWithPrefix:(NSString *)prefix
{
    unsigned numClasses;
    Class * classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    classes = objc_copyClassList(&numClasses);
    NSMutableArray *classNames = nil;
    for (NSUInteger i = 0; i < numClasses; i++) {
        NSString *class = [NSString stringWithUTF8String:class_getName(classes[i])];
        if (prefix){
            if ([class hasPrefix:prefix]) {
                if (!classNames) {
                    classNames = [NSMutableArray array];
                }
                [classNames addObject:class];
            }
        }else{
            if (!classNames) {
                classNames = [NSMutableArray array];
            }
            [classNames addObject:class];
        }
    }
    return classNames;
}

+ (NSArray *)BbStandardLibraryClassNames
{
    return [BbObject listClassesWithPrefix:@"Bb"];
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
