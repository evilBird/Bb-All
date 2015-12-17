//
//  BSDArrayFilter.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayFilter.h"
#import "BSDArrayInlet.h"

@implementation BSDArrayFilter

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"filter array";
    NSPredicate *predicate = arguments;
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.objectId = self.objectId;
    inlet.delegate = self;
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initCold];
    inlet.name = @"cold";
    inlet.objectId = self.objectId;
    inlet.delegate = self;
    return inlet;
}

- (void)calculateOutput
{
    NSArray *hot = self.hotInlet.value;
    NSArray *cold = self.coldInlet.value;
    
    if (!hot || ![hot isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (!cold || ![cold isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableArray *inputArray = hot.mutableCopy;
    NSMutableArray *predicates = cold.mutableCopy;
    NSArray *output = [self filterArray:inputArray withPredicates:predicates];
    [self.mainOutlet output:output];
}


- (NSArray *)filterArray:(NSArray *)array withPredicates:(NSArray *)predicates
{
    NSMutableArray *result = nil;
    for (NSPredicate *predicate in predicates) {
        
        if (!result) {
            result = [self filterArray:array withPredicate:predicate].mutableCopy;
        }else{
            result = [self filterArray:result.mutableCopy withPredicate:predicate].mutableCopy;
        }
    }
    
    return result;
}

- (NSArray *)filterArray:(NSArray *)array withPredicate:(NSPredicate *)predicate
{
    if (!array || !predicate || ![predicate isKindOfClass:[NSPredicate class]]) {
        return nil;
    }
    
    return [array filteredArrayUsingPredicate:predicate];
}

@end
