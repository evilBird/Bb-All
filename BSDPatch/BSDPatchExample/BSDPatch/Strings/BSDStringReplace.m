//
//  BSDStringReplace.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDStringReplace.h"

@implementation BSDStringReplace

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"str replace";
    
    self.stringToReplaceInlet = [[BSDInlet alloc]initCold];
    self.stringToReplaceInlet.name = @"toreplace";
    [self addPort:self.stringToReplaceInlet];
    
    self.replacementStringInlet = [[BSDInlet alloc]initCold];
    self.replacementStringInlet.name = @"replacement";
    [self addPort:self.replacementStringInlet];
    
    
    NSArray *args = arguments;
    if (args && [args isKindOfClass:[NSArray class]]) {
        NSString *val = [NSString stringWithFormat:@"%@",args.firstObject];
        [self.stringToReplaceInlet input:val];
        if (args.count > 1) {
            NSString *rep = [NSString stringWithFormat:@"%@",args[1]];
            [self.replacementStringInlet input:rep];
        }
    }
}


- (BSDInlet *)makeRightInlet
{
    return nil;
}


- (void)calculateOutput
{
    NSString *hot = self.hotInlet.value;
    NSString *toReplace = self.stringToReplaceInlet.value;
    NSString *replacement = [self myReplacementString:self.replacementStringInlet.value];
    if (!hot || !toReplace || !replacement) {
        return;
    }
    
    if (![hot isKindOfClass:[NSString class]]||![toReplace isKindOfClass:[NSString class]]||![replacement isKindOfClass:[NSString class]]) {
        return;
    }

    //NSString *hotCopy = [NSString stringWithString:hot];
    //NSString *toReplaceCopy = [NSString stringWithFormat:@"%@",toReplace];
    //NSString *replacementCopy = [NSString stringWithFormat:@"%@",replacement];
    NSString *output = [hot stringByReplacingOccurrencesOfString:toReplace withString:replacement];
    
    [self.mainOutlet output:output];
}

- (NSString *)myReplacementString:(NSString *)replacement
{
    NSString *myReplacement = replacement;
    if ([replacement isKindOfClass:[NSNumber class]]) {
        myReplacement = @"";
    }
    
    return myReplacement;
}


@end
