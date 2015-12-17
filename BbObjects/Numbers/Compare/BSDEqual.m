//
//  BSDEqual.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDEqual.h"

@implementation BSDEqual

- (instancetype)initWithComparisonValue:(NSNumber *)comparisonValue
{
    return [super initWithArguments:comparisonValue];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"=";
    NSNumber *initVal = (NSNumber *)arguments;
    
    if (initVal) {
        self.coldInlet.value = initVal;
    }else{
        self.coldInlet.value = @0;
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    id cold = self.coldInlet.value;
    if (!hot || !cold) {
        return;
    }
    if (![cold isKindOfClass:[hot class]]) {
        [self.mainOutlet output:@(NO)];
        return;
    }
    
    if ([cold isKindOfClass:[NSArray class]]){
        BOOL result = [cold isEqualToArray:hot];
        [self.mainOutlet output:@(result)];
        return;
    }
    
    if ([cold isKindOfClass:[NSString class]]) {
        BOOL result = [cold isEqualToString:hot];
        [self.mainOutlet output:@(result)];
        return;
    }
    
    if ([cold isKindOfClass:[NSNumber class]]) {
        BOOL result = [hot doubleValue] == [cold doubleValue];
        [self.mainOutlet output:@(result)];
        return;
    }
    BOOL result = hot == cold;
    [self.mainOutlet output:@(result)];
    
}

@end
