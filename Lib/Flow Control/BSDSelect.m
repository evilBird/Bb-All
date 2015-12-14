//
//  BSDSelect.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDSelect.h"

@implementation BSDSelect

- (instancetype)initWithSelectors:(NSArray *)selectors
{
    return [super initWithArguments:selectors];
}

- (instancetype)initAndConnectWithSelectorsAndInlets:(NSDictionary *)selectorsAndInlets
{
    return [super initWithArguments:selectorsAndInlets];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"select";
    self.coldInlet.open = NO;
    
    if ([arguments isKindOfClass:[NSArray class]]) {
        NSArray *selectors = arguments;
        for (id aSelector in selectors) {
            BSDOutlet *newOutlet = [[BSDOutlet alloc]init];
            newOutlet.name = [NSString stringWithFormat:@"%@",aSelector];
            [self addPort:newOutlet];
        }
        
    }else if ([arguments isKindOfClass:[NSDictionary class]]){
        NSDictionary *selectorsAndInlets = arguments;
        for (id aSelector in selectorsAndInlets.allKeys) {
            BSDInlet *inlet = selectorsAndInlets[aSelector];
            [self addOutletForSelector:aSelector connectToInlet:inlet];
        }
    }else if ([arguments isKindOfClass:[NSNumber class]]){
        BSDOutlet *newOutlet = [[BSDOutlet alloc]init];
        newOutlet.name = [NSString stringWithFormat:@"%@",arguments];
        [self addPort:newOutlet];
    }else if ([arguments isKindOfClass:[NSString class]]){
        BSDOutlet *newOutlet = [[BSDOutlet alloc]init];
        newOutlet.name = arguments;
        [self addPort:newOutlet];
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    NSString *key = [NSString stringWithFormat:@"%@",hot];
    BSDOutlet *outlet = [self outletNamed:key];
    if (outlet != nil) {
        [outlet output:[BSDBang bang]];
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

//create an additional outlet for the specified selector
- (BSDOutlet *)addOutletForSelector:(id)selector
{
    BSDOutlet *outlet = [[BSDOutlet alloc]init];
    outlet.name = [NSString stringWithFormat:@"%@",selector];
    [self addPort:outlet];
    return outlet;
}
- (BSDOutlet *)addOutletForSelector:(id)selector connectToInlet:(BSDInlet *)inlet
{
    BSDOutlet *outlet = [self addOutletForSelector:selector];
    [outlet connectToInlet:inlet];
    return outlet;
}

- (BSDOutlet *)outletForSelector:(id)selector
{
    NSString *outletName = [NSString stringWithFormat:@"%@",selector];
    return [self outletNamed:outletName];
}



@end
