//
//  BSDTrigger.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbTrigger.h"

@interface BbTrigger ()
{
    NSInteger bangin;
}

@property (nonatomic,strong)NSMutableArray *outletType;

@end

@implementation BbTrigger

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"t";
    bangin = NO;
    NSArray *args = arguments;
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    if (arguments && [arguments isKindOfClass:[NSArray class]]) {
        self.outletType = [NSMutableArray array];
        NSInteger idx = 0;
        for (NSString *a in args) {
            BbOutlet *outlet = [BbOutlet newOutletNamed:[@(idx) stringValue]];
            [self addPort:outlet];
            [self.outletType addObject:a];
            idx ++;
        }
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    __weak BbTrigger *weakself = self;
    return ^(id hotValue, NSArray *inlets){
        NSString *outletType = [weakself.outletType objectAtIndex:index];
        id result = nil;
        if ([outletType isEqualToString:kBbTriggerObjectBangSymbol]) {
            result = [BbBang bang];
        }else{
            result = [hotValue copy];
        }
        
        return result;
    };
}

@end
