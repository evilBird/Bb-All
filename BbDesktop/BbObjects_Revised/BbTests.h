//
//  BbTests.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@interface BbTestCase : NSObject

@property (nonatomic) NSUInteger outletIndex;
@property (nonatomic) NSInteger caseNumber;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSDictionary *inputValues;
@property (nonatomic,strong)NSString *predicateFormat;
@property (nonatomic) id expectedOutput;

+ (NSArray *)runTestsForClassName:(NSString *)className;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name outletIndex:(NSUInteger)index;
- (void)setInputValue:(id)value forInletAtIndex:(NSInteger)index;
- (id)evaluate;

@end

