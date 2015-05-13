//
//  BSDAtomizer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAtomizer.h"

@implementation BSDAtomizer

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"atomizer";
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    [self atomizeObject:hot withKey:@"atom"];
}

- (NSDictionary *)atomizeObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [object mutableCopy];
        for (id key in dict.allKeys) {
            id val = dict[key];
            NSDictionary *new = [self atomizeObject:val];
            if (new == nil) {
                NSMutableDictionary *toSend = [@{key:val}mutableCopy];
                [self.mainOutlet output:toSend];
            }else{
                return new;
            }
        }
    }else if ([object isKindOfClass:[NSArray class]]){
        NSMutableArray *arr = [object mutableCopy];
        for (id val in arr) {
            NSDictionary *new = [self atomizeObject:val];
            if (!new) {
                NSMutableDictionary *toSend = [@{@"atom":val}mutableCopy];
                [self.mainOutlet output:toSend];
            }else{
                return new;
            }
        }
    }
    
    return nil;
}

- (NSDictionary *)atomizeObject:(id)object withKey:(id)objectKey
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [object mutableCopy];
        for (id key in dict.allKeys) {
            id val = dict[key];
            NSDictionary *new = [self atomizeObject:val withKey:key];
            if (new == nil) {
                NSMutableDictionary *toSend = [@{key:val}mutableCopy];
                [self.mainOutlet output:toSend];
            }else{
                return new;
            }
        }
    }else if ([object isKindOfClass:[NSArray class]]){
        NSMutableArray *arr = [object mutableCopy];
        for (id val in arr) {
            NSDictionary *new = [self atomizeObject:val withKey:objectKey];
            if (!new) {
                NSMutableDictionary *toSend = [@{objectKey:val}mutableCopy];
                [self.mainOutlet output:toSend];
            }else{
                return new;
            }
        }
    }
    
    return nil;
}

@end
