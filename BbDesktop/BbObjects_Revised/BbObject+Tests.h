//
//  BbObject+Tests.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@interface BbObject (Tests)

+ (NSArray *)testCasesForClassName:(NSString *)className;
- (NSString *)className;
- (NSArray *)testCases;
- (NSString *)testFailedMessageFormatValue:(id)value index:(NSInteger)index caseNumber:(NSInteger)caseNumber;
- (NSString *)testPassedMessageCaseNumber:(NSInteger)caseNumber;

@end
