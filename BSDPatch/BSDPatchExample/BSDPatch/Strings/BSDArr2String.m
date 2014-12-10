//
//  BSDArr2String.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/10/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArr2String.h"

@implementation BSDArr2String

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"arr2string";
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

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    id cold = self.coldInlet.value;
    if (!hot || ![hot isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (!cold) {
        cold = @" ";
    }
    
    NSString *output = [self stringFromArray:hot withSeparator:cold];
    [self.mainOutlet output:output];
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
