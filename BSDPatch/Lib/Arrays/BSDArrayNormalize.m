//
//  BSDArrayNormalize.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayNormalize.h"
#import "BSDArrayInlet.h"
#import "BSDNumberInlet.h"

@implementation BSDArrayNormalize

- (instancetype)initWithNormalizingContstant:(NSNumber *)constant
{
    return [super initWithArguments:constant];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"normalize";
    NSNumber *constant = arguments;
    if (constant) {
        self.coldInlet.value = constant;
    }else{
        self.coldInlet.value = @(1.0);
    }
    
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initHot];
    inlet.name = @"hot";
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDNumberInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

- (NSArray *)normalizedArray:(NSArray *)array
{
    if (array) {
        NSNumber *sum = [array valueForKeyPath:@"@sum.self"];
        NSMutableArray *outputContainer = [NSMutableArray array];
        for (NSNumber *num in array) {
            NSNumber *normalizedNum = @(num.floatValue/sum.floatValue);
            [outputContainer addObject:normalizedNum];
        }
        
        return outputContainer;
    }
    
    return NULL;
}

- (void)calculateOutput
{
    self.mainOutlet.value = [self normalizedArray:[self.hotInlet.value mutableCopy]];
}



@end
