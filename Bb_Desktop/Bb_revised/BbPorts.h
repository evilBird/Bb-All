//
//  BbPorts.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBase.h"

typedef id (^BbValidateTypeBlock)(id value);
typedef void(^BbOutletOutputBlock)(id outputValue);

typedef NS_ENUM(NSUInteger, PortElementScope)
{
    PortElementScopeInput,
    PortElementScopeOutput
};

@interface BbPortElement : BbEntity

@property (nonatomic,strong)  id value;
@property (nonatomic) PortElementScope scope;

- (instancetype)initWithScope:(PortElementScope)scope;
- (void)observePortElement:(BbPortElement *)element;

@end

@interface BbPort : BbEntity

@property (nonatomic,strong)BbPortElement *inputElement;
@property (nonatomic,strong)BbPortElement *outputElement;
@property (nonatomic,readonly) NSInteger index;

- (id)outputForInputValue:(id)input;
- (id)getValue;

@end

@interface BbInlet : BbPort

@property (nonatomic,getter=isHot)BOOL hot;

+ (BbInlet *)newHotInletNamed:(NSString *)name;
+ (BbInlet *)newColdInletNamed:(NSString *)name;
- (void)input:(id)value;

@end

@interface BbOutlet : BbPort

@property (nonatomic,strong)BbOutletOutputBlock outputBlock;

+ (BbOutlet *)newOutletNamed:(NSString *)name;
- (BOOL)canConnectToInlet:(BbInlet *)inlet;
- (void)connectToInlet:(BbInlet *)inlet;
- (void)output:(id)value;

@end
