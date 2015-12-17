//
//  BSDTextParser.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDTextParser.h"
#import "BSDObjectLookup.h"

@implementation BSDTextParser


+ (id)parseArgsString:(NSString *)argsString
{
    if (!argsString || argsString.length == 0) {
        return nil;
    }
    
    id theMessage = nil;
    NSMutableString *argText = nil;
    NSString *quotesRemoved = [argsString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSInteger diff = argsString.length - quotesRemoved.length;
    NSInteger stringCount = diff;
    NSString *commasRemoved = [quotesRemoved stringByReplacingOccurrencesOfString:@"," withString:@""];
    diff = quotesRemoved.length - commasRemoved.length;
    NSInteger arraycount = diff;
    NSArray *arrays = [argsString componentsSeparatedByString:@","];
    for (NSString *anArray in arrays) {
        
    }

    
    /*
    if (diff == 2) {
        theMessage = quotesRemoved;
        argText = [[NSMutableString alloc]initWithString:theMessage];
    }else{
        NSArray *components = [argsString componentsSeparatedByString:@" "];
        if (components.count == 1) {
            id component = components.firstObject;
            argText = [[NSMutableString alloc]initWithString:component];
            theMessage = [self setTypeForString:component];
        }else {
            NSMutableArray *temp = nil;
            NSMutableString *argText = nil;
            for (id component in components) {
                
                if (!argText) {
                    argText = [[NSMutableString alloc]init];
                    [argText appendString:component];
                }else{
                    [argText appendFormat:@" %@",argText];
                }
                
                
                if (!temp) {
                    temp = [NSMutableArray array];
                }
                
                [temp addObject:[self setTypeForString:component]];
            }
            theMessage = [temp mutableCopy];
        }
        
    }
    */
    return nil;
}

+ (id)setTypeForString:(NSString *)string
{
    NSRange n = [string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    
    if (n.length > 0) {
        return string;
    }else{
        return @([string doubleValue]);
    }
}

+ (NSDictionary *)getClassNameAndArgsFromText:(NSString *)text
{
    NSString *classComponent = [BSDTextParser classNameComponentInText:text];
    NSString *argsComponent = [BSDTextParser argumentsComponentInText:text];
    NSString *className = [BSDTextParser classNameFromClassNameComponent:classComponent];
    NSArray *args = [BSDTextParser argumentsFromArgsComponent:argsComponent];
    
    NSMutableDictionary *result = nil;
    
    if (className) {
        result = [NSMutableDictionary dictionary];
        result[@"class"] = className;
    }else{
        return nil;
    }
    
    if (args) {
        result[@"args"] = args;
    }
    
    return result;
}

+ (NSString *)argumentsComponentInText:(NSString *)text
{
    NSString *classNameComponents = [BSDTextParser classNameComponentInText:text];
    NSString *temp = [text stringByReplacingOccurrencesOfString:classNameComponents withString:@""];
    NSString *result = nil;
    if (temp.length > 0) {
        NSRange first;
        first.location = 0;
        first.length = 1;
        NSString *sub = [temp substringWithRange:first];
        if ([sub isEqualToString:@" "]) {
            result = [temp stringByReplacingCharactersInRange:first withString:@""];
        }else{
            result = [NSString stringWithString:temp];
        }
    }
    return result;
}

+ (NSString *)classNameComponentInText:(NSString *)text
{
    NSArray *components = [text componentsSeparatedByString:@" "];
    NSString *first = components.firstObject;
    if (![first isEqualToString:@"patch"]) {
        if (first.length > 0) {
            return first;
        }
    }else if (components.count > 1){
        NSString *second = components[1];
        return [NSString stringWithFormat:@"%@ %@",first,second];
    }
    
    return nil;
}

+ (NSString *)classNameFromClassNameComponent:(NSString *)component
{
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    return [lookup classNameForString:component];
}

+ (NSArray *)argumentsFromArgsComponent:(NSString *)component
{
    NSMutableArray *result = nil;
    if (![BSDTextParser isCollection:component]) {
        id toAdd = nil;
        toAdd = [BSDTextParser argsForAtom:component];
        if (toAdd!=nil) {
            if (!result) {
                result = [NSMutableArray array];
            }
            [result addObject:toAdd];
        }
    }else{
        
        NSArray *args = [component componentsSeparatedByString:@","];
        for (NSString *arg in args) {
            id toAdd = nil;
            if ([BSDTextParser isDictionary:arg]) {
                toAdd = [BSDTextParser dictionaryArgWithComponent:arg];
            }else{
                toAdd = [BSDTextParser argsForAtom:arg];
            }
            
            if (toAdd != nil) {
                if (!result) {
                    result = [NSMutableArray array];
                }
                [result addObject:toAdd];
            }
        }
    }
    return result;
}

+ (id)argsForAtom:(NSString *)text
{
    if ([BSDTextParser isString:text]) {
        return [BSDTextParser stringArgWithComponent:text];
    }else {
        return [BSDTextParser numberArgWithComponent:text];
    }
}

+ (BOOL)isCollection:(NSString *)text
{
    NSRange commaRange = [text rangeOfString:@","];
    return commaRange.length > 0;
}

+ (BOOL)isDictionary:(NSString *)text
{
    NSRange colonRange = [text rangeOfString:@":"];
    return colonRange.length > 0;
}

+ (BOOL)isString:(NSString *)text
{
    NSString *quotesRemoved = [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSInteger diff = text.length - quotesRemoved.length;
    
    return diff == 2;
}

+ (NSString *)removeWhitespaceAtBeginningOfString:(NSString *)string
{
    NSRange whiteSpaceRange = [string rangeOfString:@" "];
    if (whiteSpaceRange.length == 0) {
        return string;
    }else {
        NSString *temp = nil;
        if (whiteSpaceRange.location == 0) {
            temp = [string stringByReplacingCharactersInRange:whiteSpaceRange withString:@""];
        }
        
        return [BSDTextParser removeWhitespaceAtBeginningOfString:temp];
    }
}

+ (NSDictionary *)dictionaryArgWithComponent:(NSString *)component
{
    NSDictionary *result = nil;
    NSArray *components = [component componentsSeparatedByString:@":"];
    if (components.count > 1) {
        id key = [BSDTextParser argsForAtom:components.firstObject];
        id value = [BSDTextParser argsForAtom:components[1]];
        result = @{key:value};
    }
    
    return result;
}

+ (NSString *)stringArgWithComponent:(NSString *)component
{
    NSString *result = nil;
    NSRange openQuoteRange = [component rangeOfString:@"\""];
    NSString *temp = [component stringByReplacingCharactersInRange:openQuoteRange withString:@""];
    NSRange closedQuoteRange = [temp rangeOfString:@"\""];
    result = [temp stringByReplacingCharactersInRange:closedQuoteRange withString:@""];
    return result;
}

+ (NSNumber *)numberArgWithComponent:(NSString *)component
{
    NSString *temp = [component stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSRange numberRange = [temp rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:64];
    //if (numberRange.length == temp.length) {
        return @([temp doubleValue]);
   // }
    
    return @(0);
}

@end
