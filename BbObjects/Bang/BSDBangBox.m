//
//  BSDBangBox.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBangBox.h"

@implementation BSDBangBox

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"bang";
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

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    [self calculateOutput];
}

- (void)calculateOutput
{
    self.mainOutlet.value = [BSDBang bang];
    NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self objectId]];
    NSDictionary *changeInfo = @{@"value":[BSDBang bang]};
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:changeInfo];
}

@end
