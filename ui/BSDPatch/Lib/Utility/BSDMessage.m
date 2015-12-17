//
//  BSDMessage.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMessage.h"
#import "NSString+BSD.h"

@interface BSDMultipleReturnFlag : NSObject
@property (nonatomic,strong)NSString *command;
@property (nonatomic,strong)NSArray *args;
@end
@implementation BSDMultipleReturnFlag
@end

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
    id hot = self.hotInlet.value;
    if (hot == nil) {
        return;
    }
    id output = nil;
    output = [self outputFromInput:hot];
    
    if (!output) {
        return;
    }
    
    if (![output isKindOfClass:[BSDMultipleReturnFlag class]]) {
        [self.mainOutlet output:output];
        self.lastMessage = output;
        return;
    }
    
    //If output is of class BSDMultipleReturnFlag, we need to take each element of the array, prepend any commands present to each member array, and send them out sequentially.
    BSDMultipleReturnFlag *flag = output;
    NSMutableString *displayedText = [[NSMutableString alloc]init];
    NSInteger index = 0;
    NSInteger subIndex = 0;
    BOOL setCommand = NO;
    if (flag.command && [flag.command isEqualToString:@"set"]) {
        setCommand = YES;
    }
    
    for (id anArg in flag.args) {
        //Get the input into an array
        NSMutableArray *argArray = nil;
        if ([anArg isKindOfClass:[NSArray class]]) {
            argArray = [NSMutableArray arrayWithArray:anArg];
        }else{
            argArray = [NSMutableArray arrayWithObject:anArg];
        }
        if (setCommand) {
            //Insert the proper command at the beginning of each array
            NSString *argArrayDisplayText = [self displayTextForArgs:argArray];
            if (argArrayDisplayText && argArrayDisplayText.length) {
                [displayedText appendString:argArrayDisplayText];
                id message = [self outputForSetCommandArgs:argArray displayText:argArrayDisplayText];
                [self.mainOutlet output:message];
            }
        }else if ([self countSubs:self.displayedText] > subIndex){
            NSArray *components = [self.displayedText componentsSeparatedByString:@","];
            if (components.count > index) {
                NSString *textToSub = components[index];
                NSString *interpretedText = [self makeSubs:[argArray mutableCopy]
                                         withDisplayedText:textToSub
                                                firstIndex:subIndex];
                id message = [self parseText:interpretedText];
                [self.mainOutlet output:message];
            }
            subIndex += argArray.count;
        }
        
        index++;
        
        if (setCommand && index < flag.args.count) {
            [displayedText appendString:@","];
        }
    }
    
    if (displayedText && displayedText.length > 0) {
        self.displayedText = displayedText;
    }
    
    self.lastMessage = flag;
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
        
        if (self.displayedText && [self.displayedText rangeOfString:@","].length > 0) {
            BSDMultipleReturnFlag *flag = [BSDMultipleReturnFlag new];
            flag.args = input;
            flag.command = nil;
            return flag;
        }
        
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

- (id)outputForSetCommandArgs:(id)args displayText:(NSString *)displayText
{
    if (args == nil) {
        return nil;
    }
    return [self parseText:displayText];
}

- (id)outputForCommand:(id)command args:(id)args
{
    if ([command isEqualToString:@"set"]) {
        if (args == nil) {
            self.displayedText = @"";
            return nil;
        }
        id flagArgs = [self flagArgsForMultipleReturns:args command:command];
        if (flagArgs) {
            return flagArgs;
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
    
    if ([text isEqualToString:@" "]) {
        return @[text];
    }
    
    if ([text isStringLiteral]) {
        return [text stringFromLiteral];
    }
    
    /*
    if ([[text substringToIndex:1] isEqualToString:@"\""] && [[text substringToIndex:text.length]isEqualToString:@"\""]) {
        NSString *s1 = [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *s2 = [s1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        return @[s2];
    }
     */
    
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
    NSRange punc = [string rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]];
    NSRange ws = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (r.length == 0 && sym.length == 0 && punc.length == 0 && ws.length == 0) {
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

- (NSString *)makeSubs:(id)input withDisplayedText:(NSString *)text firstIndex:(NSInteger)firstIndex
{
    NSString *result = [NSString stringWithString:text];
    for (NSInteger i = 0; i < [input count]; i ++) {
        NSInteger j = i+firstIndex+1;
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

- (id)flagArgsForMultipleReturns:(id)args command:(NSString *)command
{
    if (!args || ![args isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSArray *toEnumerate = args;
    for (id anArg in toEnumerate) {
        if ([anArg isKindOfClass:[NSArray class]]) {
            BSDMultipleReturnFlag *flag = [BSDMultipleReturnFlag new];
            flag.args = args;
            flag.command = command;
            return flag;
        }
    }
    
    return nil;
}

@end
