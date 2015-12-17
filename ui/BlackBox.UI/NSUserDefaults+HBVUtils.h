//
//  NSUserDefaults+HBVUtils.h
//  Herbivore
//
//  Created by Travis Henspeter on 1/14/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (HBVUtils)

+ (BOOL)setUserValue:(id)value forKey:(id)key;
+ (id)valueForKey:(NSString *)key;
+ (NSString *)methodKey;

@end
