//
//  BSDSuperview.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDScreen.h"
#import "NSValue+BSD.h"
@interface BSDScreen ()
{
    UIInterfaceOrientation orientation;
}


@end

@implementation BSDScreen

+ (NSString *)listeningChannel
{
    return kScreenDelegateChannel;
}

- (void)pingCanvas
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kScreenDelegateChannel object:self];
}

- (void)setDelegate:(id<BSDScreenDelegate>)delegate
{
    _delegate = delegate;
    NSLog(@"window %@ got its delegate",[self objectId]);
    [self.viewInlet input:[self.delegate canvasScreen]];
}

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

-(void)notification_OrientationWillChange:(NSNotification*)n
{
    orientation = (UIInterfaceOrientation)[[n.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
}

-(void)notification_OrientationDidChange:(NSNotification*)n
{
    NSValue *rect = [NSValue wrapRect:[[UIScreen mainScreen]bounds]];
    [self.setterInlet input:@{@"frame":rect}];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    [self pingCanvas];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_OrientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_OrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (NSString *)displayName
{
    return @"screen";
}

- (UIView *)makeMyView
{
    if (!self.delegate) {
        return nil;
    }
    return [self.delegate canvasScreen];
}

- (void)tearDown
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    self.delegate = nil;
    [super tearDown];
}

@end
