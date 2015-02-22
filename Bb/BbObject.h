//
//  BbObj.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBase.h"
#import "BbPorts.h"

typedef id (^BbCalculateOutputBlock)(id hotValue, NSArray *inlets);

@interface BbObject : BbEntity

@property (nonatomic,strong)    NSArray             *creationArguments;

@property (nonatomic)           NSArray             *inlets;
@property (nonatomic)           NSArray             *outlets;
@property (nonatomic)           NSArray             *childObjects;

@property (nonatomic,strong)    NSMutableArray      *inlets_;
@property (nonatomic,strong)    NSMutableArray      *outlets_;
@property (nonatomic,strong)    NSMutableOrderedSet *childObjects_;

@property (nonatomic)           BbInlet             *hotInlet;
@property (nonatomic)           BbInlet             *coldInlet;
@property (nonatomic)           BbOutlet            *mainOutlet;

+ (NSString *)UIType;
+ (NSString *)stackInstruction;

- (instancetype)initWithArguments:(id)arguments;
- (void)setupWithArguments:(id)arguments;
- (void)commonInitArgs:(id)args;
- (void)addPort:(BbPort *)port;
- (id)outputForOutlet:(BbOutlet *)outlet withChangeInHotInlet:(BbInlet *)hotInlet;
- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index;

- (NSString *)textDescription;
- (BOOL)hasUI;
- (BOOL)needsUI;
- (BOOL)wantsUI;
- (NSArray *)UIPosition;
- (NSArray *)UISize;


@end

