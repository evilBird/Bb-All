//
//  BbJSObject.m
//  JavaScriptThingy
//
//  Created by Travis Henspeter on 1/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BSDJSObject.h"

@implementation BSDJSObject

- (BOOL)isNumber:(NSString *)string
{
    NSRange numRange = [string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    NSRange letterRange = [string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if (letterRange.length == 0 && numRange.length > 0) {
        return YES;
    }
    
    return NO;
}

@end

@implementation BSDJSFunction

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"JSFunction";
}

- (void)calculateOutput
{
    NSString *hot = [self.hotInlet.value copy];
    NSString *cold = [self.coldInlet.value copy];
    UIWebView *webview = [UIWebView new];
    NSString *jsExpression = [NSString stringWithFormat:hot,cold];
    NSString *outputString = [webview stringByEvaluatingJavaScriptFromString:jsExpression];
    id output = [outputString copy];
    if ([self isNumber:outputString]) {
        output = @([outputString floatValue]);
    }
    
    [self.mainOutlet output:output];
}

@end


@implementation BSDJSScript : BSDJSObject

- (void)setupWithArguments:(id)arguments
{
    self.name = @"JSScript";
}

- (BSDInlet *)makeColdInlet
{
    return nil;
}

- (void)calculateOutput
{
    NSString *hot = [self.hotInlet.value copy];
    UIWebView *webview = [UIWebView new];
    NSString *outputString = [webview stringByEvaluatingJavaScriptFromString:hot];
    id output = [outputString copy];
    if ([self isNumber:outputString]) {
        output = @([outputString floatValue]);
    }
    [self.mainOutlet output:output];
    
}

@end