//
//  BbTests.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbTests.h"
#import "BbBasicMath.h"
#import "BbStrings.h"
#import "BbObject+Tests.h"
#import "BbObject+Decoder.h"

@implementation BbTestCase

+ (NSArray *)runTestsForClassName:(NSString *)className
{
    NSArray *testCases = [BbObject testCasesForClassName:className];
    NSMutableArray *results = [NSMutableArray array];
    for (BbTestCase *testCase in testCases) {
        NSString *message = [testCase evaluate];
        [results addObject:message];
    }
    
    return results;
}

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name outletIndex:0];
}

- (instancetype)initWithName:(NSString *)name outletIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        _name = name;
        _outletIndex = index;
    }
    return self;
}

- (void)setInputValue:(id)value forInletAtIndex:(NSInteger)index
{
    if (!self.inputValues) {
        self.inputValues = [NSDictionary dictionaryWithObject:value forKey:@(index)];
    }else{
        NSMutableDictionary *inputValuesCopy = self.inputValues.mutableCopy;
        [inputValuesCopy setObject:value forKey:@(index)];
        self.inputValues = [NSDictionary dictionaryWithDictionary:inputValuesCopy];
    }
}

- (void)setExpectedOutput:(id)expectedOutput
{
    _expectedOutput = expectedOutput;
    NSString *predicateFormat = [NSString stringWithFormat:@"%@ == %@",@"%@",expectedOutput];
    self.predicateFormat = [predicateFormat copy];
}

- (id)evaluate
{
    BbObject *object = [BbObject newObjectClassName:self.name arguments:nil];
    return [self evaluateWithObject:object];
}

- (id)evaluateWithObject:(BbObject *)object
{
    NSString *message = nil;
    [self setInputsForObject:object withDictionary:self.inputValues];
    id output = [[object.outlets[self.outletIndex] getValue]copy];
    if (!output) {
        message = [object testFailedMessageFormatValue:self.expectedOutput index:self.outletIndex caseNumber:self.caseNumber];
        return message;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:self.predicateFormat,output];
    NSArray *toFilter = @[output];
    NSArray *filtered = [toFilter filteredArrayUsingPredicate:predicate];
    if (filtered.count == toFilter.count) {
        message = [object testPassedMessageCaseNumber:self.caseNumber];
    }else{
        message = [object testFailedMessageFormatValue:self.expectedOutput index:self.outletIndex caseNumber:self.caseNumber];
    }
    NSString *result = [NSString stringWithString:message];
    [object tearDown];
    return result;
}

- (void)setInputsForObject:(BbObject*)object withDictionary:(NSDictionary *)dictionary
{
    NSSortDescriptor *sortDescending = [NSSortDescriptor sortDescriptorWithKey:@"integerValue" ascending:NO];
    NSArray *sortedInletKeys = [dictionary.allKeys sortedArrayUsingDescriptors:@[sortDescending]];
    for (NSNumber *inletIndex in sortedInletKeys) {
        if (inletIndex.integerValue < object.inlets.count) {
            BbInlet *inlet = object.inlets[inletIndex.integerValue];
            [inlet input:dictionary[inletIndex]];
        }
    }
}

@end