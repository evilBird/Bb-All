//
//  BSDMessage.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMessage.h"

typedef id (^ArgHandler)(id);

@interface BSDMessage ()

@property (nonatomic,strong)id lastMessage;
@property (nonatomic,strong)NSString *displayedText;

@end

@implementation BSDMessage

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.hotInlet.delegate = self;
    self.name = @"message";
    self.lastMessage = nil;
    if (arguments != nil){
        [self.hotInlet input:@{@"set":arguments}];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    /*
     
     id theMessage = [self theMessage];
     if (theMessage == nil) {
     return;
     }
     
     [self.mainOutlet output:theMessage];
     
     NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self objectId]];
     NSDictionary *changeInfo = @{@"value":theMessage};
     [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:changeInfo];
     self.lastMessage = theMessage;
     */
    
    id hot = self.hotInlet.value;
    if (hot == nil) {
        return;
    }
    id output = [self outputFromInput:hot];
    if (output) {
        [self.mainOutlet output:output];
        self.lastMessage = output;
    }
}

- (void)setDisplayedText:(NSString *)displayedText
{
    _displayedText = displayedText;
    NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self objectId]];
    NSDictionary *changeInfo = @{@"value":displayedText};
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:changeInfo];
}

- (id)outputFromInput:(id)input
{
    if ([input isKindOfClass:[BSDBang class]]) {
        return self.lastMessage;
    }
    
    if (![input isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *inputArray = [input mutableCopy];
    NSString *command = [inputArray firstObject];
    NSArray *args = nil;
    if ([inputArray count] > 1) {
        [inputArray removeObjectAtIndex:0];
        args = inputArray;
    }
    
    NSArray *commands = [self allowedCommands];
    
    if ([commands containsObject:command]) {
        return [self outputForCommand:command args:args];
    }else{
        NSInteger subCount = [self countSubs:self.displayedText];
        if (subCount == 0) {
            return nil;
        }
        
        NSString *interpretedText = [self makeSubs:[input mutableCopy]];
        return [self parseText:interpretedText];
    }
    
}

- (NSArray *)allowedCommands
{
    return @[@"set",@"add2",@"addcomma"];
}

- (id)outputForCommand:(id)command args:(id)args
{
    if ([command isEqualToString:@"set"]) {
        if (args == nil) {
            self.displayedText = @"";
            return nil;
        }
        
        self.displayedText = [self displayTextForArgs:args];
        return [self parseText:self.displayedText];
    }
    if ([command isEqualToString:@"add2"]) {
        if (args == nil) {
            return [self parseText:self.displayedText];
        }
        NSString *toAdd = [self displayTextForArgs:args];
        self.displayedText = [self.displayedText stringByAppendingFormat:@" %@",toAdd];
        return [self parseText:self.displayedText];
    }
    
    if ([command isEqualToString:@"addcomma"]) {
        NSString *toAdd = @",";
        self.displayedText = [self.displayedText stringByAppendingFormat:@" %@",toAdd];
        return [self parseText:self.displayedText];
    }
    
    return nil;
}

- (id)parseText:(NSString *)text
{
    NSMutableArray *result = nil;
    NSArray *components = [text componentsSeparatedByString:@" "];
    for (NSString *aComponent in components) {
        id toAdd = [self typeForString:aComponent];
        if (!result) {
            result = [NSMutableArray array];
        }
        
        [result addObject:toAdd];
    }
    
    if (result.count == 1) {
        return result.firstObject;
    }
    
    return result;
}

- (id)typeForString:(NSString *)string
{
    NSRange r = [string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    NSRange sym = [string rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]];
    if (r.length == 0 && sym.length == 0) {
        return @(string.floatValue);
    }
    return string;
}

- (NSInteger)countSubs:(NSString *)text
{
    NSInteger result = 0;
    NSRange range = [text rangeOfString:@"$"];
    
    while (range.length > 0) {
        result +=1;
        range.length = 2;
        text = [text stringByReplacingCharactersInRange:range withString:@""];
        range = [text rangeOfString:@"$"];
    }
    
    return result;
}

- (NSString *)makeSubs:(id)input
{
    NSString *result = [NSString stringWithString:self.displayedText];
    for (NSInteger i = 0; i < [input count]; i ++) {
        NSInteger j = i+1;
        NSString *sub = [NSString stringWithFormat:@"$%@",@(j)];
        NSString *replacement = [NSString stringWithFormat:@"%@",input[i]];
        result = [result stringByReplacingOccurrencesOfString:sub withString:replacement];
    }
    
    return result;
}

- (NSString *)displayTextForArgs:(id)args
{
    if (args == nil) {
        return @"";
    }
    
    NSMutableString *result = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i < [args count]; i ++) {
        if (i != 0) {
            [result appendString:@" "];
        }
        
        [result appendFormat:@"%@",args[i]];
    }
    
    return result;
}

- (id)theMessage
{
    id hot = self.hotInlet.value;
    id value = nil;
    if (hot == nil) {
        return nil;
    }
    
    if ([hot isKindOfClass:[BSDBang class]]) {
        return self.lastMessage;
    }
    
    if ([hot isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [hot mutableCopy];
        if (arr.count < 2) {
            return nil;
        }
        
        NSString *key = [arr.firstObject lowercaseString];
        [arr removeObject:arr.firstObject];
        value = arr;
        if (![key isEqualToString:@"set"]) {
            return nil;
        }
        return value;
    }
    
    if ([hot isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [hot mutableCopy];
        if (dict.allKeys.count < 1) {
            return nil;
        }
        NSString *key = dict.allKeys.firstObject;
        if (![[key lowercaseString] isEqualToString:@"set"]) {
            return nil;
        }
        return dict.allValues.firstObject;
    }
    
    if ([hot isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@",hot];
    }
    
    if ([hot isKindOfClass:[NSNumber class]]) {
        double num = [hot doubleValue];
        return @(num);
    }
    
    return nil;
}

@end
