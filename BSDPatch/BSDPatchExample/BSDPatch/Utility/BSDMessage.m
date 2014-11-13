//
//  BSDMessage.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMessage.h"

@interface BSDMessage ()

@property (nonatomic,strong)id lastMessage;

@end

@implementation BSDMessage

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.hotInlet.delegate = self;
    self.name = @"message";
    self.lastMessage = nil;
    if (arguments != nil){
        [self.hotInlet input:@{@"set":arguments}];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    id theMessage = [self theMessage];
    if (theMessage == nil) {
        return;
    }
    
    [self.mainOutlet output:theMessage];
    
    NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self objectId]];
    NSDictionary *changeInfo = @{@"value":theMessage};
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:changeInfo];
    self.lastMessage = theMessage;
}

- (id)theMessage
{
    id hot = self.hotInlet.value;
    id value = nil;
    if (hot == nil) {
        return nil;
    }
    
    if ([hot isKindOfClass:[BSDBang class]]) {
        return self.lastMessage;
    }
    
    if ([hot isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [hot mutableCopy];
        if (arr.count < 2) {
            return nil;
        }
        
        NSString *key = [arr.firstObject lowercaseString];
        [arr removeObject:arr.firstObject];
        value = arr;
        if (![key isEqualToString:@"set"]) {
            return nil;
        }
        return value;
    }
    
    if ([hot isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [hot mutableCopy];
        if (dict.allKeys.count < 1) {
            return nil;
        }
        NSString *key = dict.allKeys.firstObject;
        if (![[key lowercaseString] isEqualToString:@"set"]) {
            return nil;
        }
        return dict.allValues.firstObject;
    }
    
    if ([hot isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@",hot];
    }
    
    if ([hot isKindOfClass:[NSNumber class]]) {
        double num = [hot doubleValue];
        return @(num);
    }
    
    return nil;
}


@end
