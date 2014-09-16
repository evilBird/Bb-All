//
//  NSUserDefaults+HBVUtils.m
//  Herbivore
//
//  Created by Travis Henspeter on 1/14/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import "NSUserDefaults+HBVUtils.h"

@implementation NSUserDefaults (HBVUtils)



+ (NSString *)methodKey
{
    NSArray *stacks = [NSUserDefaults stacksWithMax:4];
    NSDictionary *components = stacks.lastObject;
    return components[@"method"];
}

+ (NSArray *)stacksWithMax:(NSUInteger)max
{
    NSMutableArray *stacks = [NSMutableArray array];
    NSInteger idx = 0;
    for (NSString *sourceString in [NSThread callStackSymbols]) {
        NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
        [array removeObject:@""];
        idx ++;
        if (array.count >= 5 && idx < max) {
            NSDictionary *componentDictionary = @{@"stack": array[0],
                                                  @"id": array[2],
                                                  @"class":array[3],
                                                  @"method":array[4]
                                                  };
            [stacks addObject:componentDictionary];
            
        }
        
    }
    
    return stacks;
}


+ (BOOL)setUserValue:(id)value forKey:(id)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:key];
    return [userDefaults synchronize];
}

+ (id)valueForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:key];
}


@end
