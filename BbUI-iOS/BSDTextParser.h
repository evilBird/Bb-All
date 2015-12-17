//
//  BSDTextParser.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSDTextParser : NSObject

+ (id)parseArgsString:(NSString *)argsString;


+ (NSDictionary *)getClassNameAndArgsFromText:(NSString *)text;
+ (NSArray *)argumentsFromArgsComponent:(NSString *)component;


@end
