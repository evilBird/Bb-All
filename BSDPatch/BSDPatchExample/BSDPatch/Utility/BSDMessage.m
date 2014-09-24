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
    self.name = message;
    [[NSNotificationCenter defaultCenter]postNotificationName:[self notificationName] object:[self notificationObject]];
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
    if (inlet == self.hotInlet && self.message != nil) {
        NSLog(@"bang in message box");
        [self.mainOutlet setValue:self.message];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        NSArray *arr = value;
        NSDictionary *dict = value;
        if ([arr isKindOfClass:[NSArray class]] && arr.count == 2) {
            NSString *key = [arr firstObject];
            if ([key isEqualToString:@"set"]) {
                [self setTheMessage:arr[1]];
                self.name = self.message;
            }
        }else if ([dict isKindOfClass:[NSDictionary class]] && dict.allKeys.count == 1){
            NSString *key = dict.allKeys.firstObject;
            if ([key isEqualToString:@"set"]) {
                [self setTheMessage:dict[key]];
                self.name = self.message;
            }
        }
    }
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
