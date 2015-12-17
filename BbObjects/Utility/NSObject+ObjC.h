//
//  NSObject+ObjC.h
//  classLookup
//
//  Created by Travis Henspeter on 12/9/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#ifndef NSObject_ObjC_h
#define NSObject_ObjC_h
#import <Foundation/Foundation.h>

@interface NSObject (ObjC)

+ (NSArray *)getClassList;
+ (NSArray *)getClassNamesMatchingPattern:(NSString *)matchingPattern;
+ (NSArray *)getMethodListForClass:(NSString *)className;
+ (NSArray *)getMethodListForClass:(NSString *)className matchingPattern:(NSString *)matchingPattern;

@end

#endif /* NSObject_ObjC_h */
