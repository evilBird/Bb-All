//
//  BSDAdd.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAdd.h"

@implementation BSDAdd

- (instancetype)initWithPlusValue:(NSNumber *)plusValue
{
    return [super initWithArguments:plusValue];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"+";
    NSNumber *plusValue = arguments;
    if (plusValue && [plusValue isKindOfClass:[NSNumber class]]) {
        self.coldInlet.value = plusValue;
    }else if (plusValue && [plusValue isKindOfClass:[NSArray class]]){
        NSArray *args = arguments;
        id first = args.firstObject;
        if ([first isKindOfClass:[NSNumber class]]) {
            self.coldInlet.value = first;
        }else{
            self.coldInlet.value = @0;
        }
    }else{
        self.coldInlet.value = @0;
    }
}

- (void)calculateOutput
{
    NSNumber *hot = self.hotInlet.value;
    NSNumber *cold = self.coldInlet.value;
    if (!hot || !cold) {
        return;
    }
    NSNumber *output = @(hot.doubleValue + cold.doubleValue);
    [self.mainOutlet output:output];
    
}

@end
