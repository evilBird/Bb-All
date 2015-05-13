//
//  BSDNumber.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNumber.h"

@implementation BSDNumber

- (instancetype)initWithValue:(NSNumber *)value
{
    return [super initWithArguments:value];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"number";
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}


- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSNumber *val = self.hotInlet.value;
    if ([val isKindOfClass:[NSNumber class]]) {
        [self.mainOutlet output:val];
        NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self objectId]];
        NSDictionary *changeInfo = @{@"value":@(val.doubleValue)};
        [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:changeInfo];
    }
}

@end
