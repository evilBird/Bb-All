//
//  BSDTrigger.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDTrigger.h"

@interface BSDTrigger ()

@property (nonatomic,strong)NSMutableArray *sequencedOutlets;
@property (nonatomic,strong)NSMutableArray *outletType;

@end

@implementation BSDTrigger

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"t";
    NSArray *args = arguments;
    if (args && [args isKindOfClass:[NSArray class]]) {
        self.sequencedOutlets = [NSMutableArray array];
        self.outletType = [NSMutableArray array];
        NSInteger idx = 0;
        for (NSString *a in args) {
            BSDOutlet *outlet = [[BSDOutlet alloc]init];
            outlet.name = [NSString stringWithFormat:@"%@",@(idx)];
            [self addPort:outlet];
            [self.sequencedOutlets addObject:outlet];
            [self.outletType addObject:a];
            
            idx ++;
        }
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    
    if (hot == nil) {
        return;
    }
    
    NSInteger idx = self.sequencedOutlets.count - 1;
    while (idx > -1) {
        BSDOutlet *outlet = self.sequencedOutlets[idx];
        NSString *type = self.outletType[idx];
        if ([type isEqualToString:@"v"]) {
            [outlet output:hot];
        }else if ([type isEqualToString:@"b"]){
            [outlet output:[BSDBang bang]];
        }
        idx--;
    }
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

@end
