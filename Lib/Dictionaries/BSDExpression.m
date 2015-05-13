//
//  BSDExpression.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDExpression.h"

@implementation BSDExpression

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"expression";
    self.argsInlet = [[BSDInlet alloc]initCold];
    self.argsInlet.delegate = self;
    self.argsInlet.name = @"args";
    [self addPort:self.argsInlet];
    
    self.contextInlet = [[BSDInlet alloc]initCold];
    self.contextInlet.delegate = self;
    self.contextInlet.name = @"context";
    [self addPort:self.contextInlet];
    
}

- (void)calculateOutput
{
    id object = self.hotInlet.value;
    NSString *formatString = self.coldInlet.value;
    NSArray *argArr = self.argsInlet.value;
    if (![formatString isKindOfClass:[NSString class]] || ![argArr isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSExpression *expression = [NSExpression expressionWithFormat:formatString argumentArray:argArr];
    id output = [expression expressionValueWithObject:object context:self.contextInlet.value];
    [self.mainOutlet output:output];
}

@end
