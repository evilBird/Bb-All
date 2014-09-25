//
//  BSDMessage.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMessage.h"

@interface BSDMessage ()

@property (nonatomic,strong)id message;


@end

@implementation BSDMessage

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setTheMessage:(id)message
{
    self.message = message;
}

- (void)setupWithArguments:(id)arguments
{
    self.hotInlet.delegate = self;
    if (arguments != nil){
        self.name = [NSString stringWithFormat:@"%@",arguments];
        self.message = arguments;
    }else{
        self.name = @"";
        self.message = nil;
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
    id theMessage = [self theMessage];
    [self.mainOutlet output:[self theMessage]];
    NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self objectId]];
    NSDictionary *changeInfo = @{@"value":theMessage};
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:changeInfo];
}

- (id)theMessage
{
    id hot = self.hotInlet.value;
    id value = nil;
    if (hot == nil) {
        return nil;
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
    
    return nil;
}

- (NSString *)notificationName
{
    return [NSString stringWithFormat:@"com.birdSound.BlockBox-UI.messageBoxValueChanged-%@",self.objectId];
}

- (NSDictionary *)notificationObject
{
    return @{@"message":self.message};
}

@end
