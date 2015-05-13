//
//  BSDReceive.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDReceive.h"
#import "BSDSend.h"

@interface BSDReceive ()

@property (nonatomic,strong)NSString *notificationExtension;

@end

@implementation BSDReceive

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"r";
    if (arguments && [arguments isKindOfClass:[NSString class]]) {
        self.notificationExtension = [NSString stringWithString:arguments];
    }else if (arguments && [arguments isKindOfClass:[NSArray class]]){
        NSLog(@"args for receive object are of type array");
    }
    
    if (self.notificationExtension) {
        NSString *notificationName = [NSString stringWithFormat:@"%@.%@",kSendNotificationBase,self.notificationExtension];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(handleNotification:)
                                                    name:notificationName
                                                  object:nil];
        
    }
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)handleNotification:(NSNotification *)notification
{
    id object = notification.object;
    
    if (object == nil) {
        return;
    }
    
    [self.mainOutlet output:object];
}

- (void)tearDown
{
    NSString *notificationName = [NSString stringWithFormat:@"%@.%@",kSendNotificationBase,self.notificationExtension];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notificationName object:nil];
    [super tearDown];
}

@end
