//
//  BSDSend.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDSend.h"

@interface BSDSend ()


@end

@implementation BSDSend

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"s";
    
    if (arguments && [arguments isKindOfClass:[NSString class]]) {
        self.coldInlet.value = arguments;
    }else if (arguments && [arguments isKindOfClass:[NSArray class]]){
        NSLog(@"args to send object are of array type");
    }
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (NSString *)notificationName
{
    id cold = self.coldInlet.value;
    if (!cold || ![cold isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *extension = [NSString stringWithString:cold];
    return [NSString stringWithFormat:@"%@.%@",kSendNotificationBase,extension];
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        NSString *notificationName = [self notificationName];
        if (!notificationName) {
            return;
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:[BSDBang bang]];
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    
    if (hot == nil) {
        return;
    }
    
    NSString *notificationName = [self notificationName];
    
    if (!notificationName) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:hot];
}

@end
