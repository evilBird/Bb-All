//
//  BSDTrigger.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDTrigger.h"

@interface BSDTrigger ()
{
    NSInteger bangin;
}
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
    bangin = NO;
    NSArray *args = arguments;
    if (args && [args isKindOfClass:[NSArray class]]) {
        self.sequencedOutlets = [NSMutableArray array];
        self.outletType = [NSMutableArray array];
        NSInteger idx = 0;
        for (NSString *a in args) {
            BSDOutlet *outlet = [[BSDOutlet alloc]init];
            outlet.name = [NSString stringWithFormat:@"outlet-%@",[NSNumber numberWithInteger:idx].stringValue];
            [self addPort:outlet];
            [self.sequencedOutlets addObject:outlet];
            [self.outletType addObject:a];
            
            idx ++;
        }
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    
    NSEnumerator *enumerator = [self.sequencedOutlets reverseObjectEnumerator];
    NSArray *reversed = enumerator.allObjects;
    NSInteger idx = self.sequencedOutlets.count - 1;
    for (BSDOutlet *anOutlet in reversed) {

        NSString *type = self.outletType[idx];
        if ([type isEqualToString:@"b"]) {
            [anOutlet output:[BSDBang bang]];
        }else if ([type isEqualToString:@"v"]){
            [anOutlet output:hot];
        }
        idx -= 1;
    }
    
    /*
    
    
    if (!self.sequencedOutlets || self.sequencedOutlets.count == 0) {
        return;
    }
    
    NSInteger idx = self.sequencedOutlets.count - 1;
    while (idx >= 0) {
        BSDOutlet *outlet = self.sequencedOutlets[idx];
        NSString *type = self.outletType[idx];
        if ([type isEqualToString:@"v"]) {
                [outlet output:hot];
        }else if ([type isEqualToString:@"b"]){
             outlet.value = [[BSDBang alloc]init];
        }
        idx--;
    }
     */
    
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
