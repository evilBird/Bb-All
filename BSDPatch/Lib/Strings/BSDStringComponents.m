//
//  BSDStringComponents.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/10/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDStringComponents.h"

@implementation BSDStringComponents

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"string components";
    if (!arguments) {
        return;
    }
    
    if ([arguments isKindOfClass:[NSString class]]) {
        [self.coldInlet input:arguments];
        return;
    }
    
    if ([arguments isKindOfClass:[NSArray class]]) {
        NSArray *args = arguments;
        if ([args.firstObject isKindOfClass:[NSString class]]) {
            [self.coldInlet input:args.firstObject];
            return;
        }
    }
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.delegate = self;
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    id cold = self.coldInlet.value;
    if (!hot || !cold) {
        return;
    }
    
    NSString *base = nil;
    NSString *sep = nil;
    if ([hot isKindOfClass:[NSString class]]) {
        base = hot;
    }else if ([hot isKindOfClass:[NSArray class]]){
        base = [self stringFromArray:hot withSeparator:@" "];
    }
    
    if ([cold isKindOfClass:[NSString class]]) {
        sep = cold;
    }else if ([cold isKindOfClass:[NSArray class]]){
        sep = [self stringFromArray:cold withSeparator:nil];
    }
    
    if (!base || !sep) {
        return;
    }
    
    NSArray *output = [base componentsSeparatedByString:sep];
    [self.mainOutlet output:output.mutableCopy];
}

- (NSString *)stringFromArray:(NSArray *)array withSeparator:(NSString *)separator
{
    if (!array) {
        return nil;
    }
    
    NSMutableString *result = [NSMutableString string];
    NSInteger index = 0;
    for (NSString *component in array) {
        [result appendString:component];
        index++;
        
        if (index < array.count && separator) {
            [result appendString:separator];
        }
    }
    
    return result;
}

@end
