//
//  BbMessageParser.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbMessageParser.h"
#import "NSMutableArray+MessageQueue.h"

@interface BbMessageParser ()

@end

@implementation BbMessageParser

+ (id)messageFromText:(NSString *)text
{
    NSMutableArray *messageBuffer = [NSMutableArray array];
    NSMutableArray *arrayBuffer = [NSMutableArray array];
    NSString *stringBuffer = [NSString new];
    NSCharacterSet *quote = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSCharacterSet *space = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSCharacterSet *allNoQuotes = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890,./?><;:!@#$%^&*()~`'<>-_=+ "];
    NSCharacterSet *allNoQuotesNoCommasNoSpaces = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890./?><;:!@#$%^&*()~`'<>-_=+"];
    NSScanner *scanner = [NSScanner scannerWithString:text];
    scanner.charactersToBeSkipped = nil;
    NSUInteger quoteCount = 0;
    BOOL done = NO;
    
    while (!done) {
        
        NSUInteger quoteWasOpen = (quoteCount%2 == 1);
        NSUInteger scannedQuote = [scanner scanCharactersFromSet:quote intoString:NULL];
        quoteCount += scannedQuote;
        NSUInteger quoteIsOpen = (quoteCount%2 == 1);
        BOOL scannedComma = [scanner scanCharactersFromSet:comma intoString:NULL];
        BOOL scannedSpace = [scanner scanCharactersFromSet:space intoString:NULL];
        
        if (scannedQuote && quoteWasOpen && !quoteIsOpen) {
            if (stringBuffer.length) {
                NSString *addToMessageBuffer = [NSString stringWithString:stringBuffer];
                [messageBuffer addObject:addToMessageBuffer];
                NSLog(@"add %@ to message buffer",addToMessageBuffer);
                stringBuffer = [NSString new];
            }
        }else if (scannedComma && !quoteIsOpen){
            if (stringBuffer.length) {
                NSString *addToArrayBuffer = [NSString stringWithString:stringBuffer];
                [arrayBuffer addObject:addToArrayBuffer];
                stringBuffer = [NSString new];
            }
            
            if (arrayBuffer.count) {
                NSArray *addToMessageBuffer = [NSArray arrayWithArray:arrayBuffer];
                [messageBuffer addObject:addToMessageBuffer];
                arrayBuffer = [NSMutableArray array];
            }
        }else if (scannedSpace && !quoteIsOpen){
            if (stringBuffer.length) {
                NSString *addToArrayBuffer = [NSString stringWithString:stringBuffer];
                [arrayBuffer addObject:addToArrayBuffer];
                stringBuffer = [NSString new];
            }
            
        }else{
            if (quoteIsOpen){
                [scanner scanCharactersFromSet:allNoQuotes intoString:&stringBuffer];
            }else{
                [scanner scanCharactersFromSet:allNoQuotesNoCommasNoSpaces intoString:&stringBuffer];
                NSLog(@"string buffer: %@",stringBuffer);
            }
        }
        
        done = scanner.isAtEnd;
    }
    
    if (stringBuffer.length) {
        NSString *addToArrayBuffer = [NSString stringWithString:stringBuffer];
        [arrayBuffer addObject:addToArrayBuffer];
        stringBuffer = nil;
    }
    
    if (arrayBuffer.count) {
        NSArray *addToMessageBuffer = [NSArray arrayWithArray:arrayBuffer];
        [messageBuffer addObject:addToMessageBuffer];
        arrayBuffer = nil;
    }
    
    return messageBuffer;
}

+ (id)setTypeForString:(NSString *)string
{
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"1234567890."];
    NSScanner *numberScanner = [NSScanner scannerWithString:string];
    NSString *stringBuffer = [NSString new];
    BOOL done = NO;
    id result = nil;
    BOOL didScanNumbers = NO;
    while (!done) {
        didScanNumbers = [numberScanner scanCharactersFromSet:numbers intoString:&stringBuffer];
        done = numberScanner.isAtEnd;
        if (!didScanNumbers) {
            done = YES;
        }
    }
    
    if (stringBuffer.length == string.length) {
        //it's a number; determine whether float or int
        if ([stringBuffer rangeOfString:@"."].length > 0){
            result = @([string doubleValue]);
        }else{
            result = @([string integerValue]);
        }
    }else{
        result = [NSString stringWithString:string];
    }
    
    return result;
}

@end
