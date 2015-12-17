//
//  BSDTouchGenerator.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDTouchGenerator.h"
#import "BSDCreate.h"

@interface BSDTouchGenerator ()<UIGestureRecognizerDelegate>

@end

@implementation BSDTouchGenerator

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"touch generator";
    UIPanGestureRecognizer *panrecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(receivedNewData:)];
    self.coldInlet.value = panrecognizer;
    self.touchesOutlet = [[BSDOutlet alloc]init];
    self.touchesOutlet.name = @"touches";
    [self addPort:self.touchesOutlet];
}

- (void)receivedNewData:(id)data
{
    UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)data;
    if (!gesture) {
        return;
    }
    
    UIView *view = gesture.view;
    static NSDate *startDate;
    static NSValue *origin;
    NSTimeInterval duration = 0;
    NSMutableDictionary *output = nil;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        startDate = [NSDate date];
        origin = [NSValue valueWithCGPoint:[gesture locationInView:view]];
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        duration = [[NSDate date]timeIntervalSinceDate:startDate];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        duration = [[NSDate date]timeIntervalSinceDate:startDate];
        startDate = nil;
        origin = nil;
    }
    
    if (output == nil) {
        output = [NSMutableDictionary dictionary];
    }
    
    output[@"state"] = @(gesture.state);
    output[@"duration"] = @(duration);
    
    if (view != nil) {
        output[@"view"] = view;
        output[@"location"]= [NSValue wrapPoint:[gesture locationInView:view]],
        output[@"velocity"] = [NSValue wrapPoint:[gesture velocityInView:view]];
    }
    
    if (origin != nil) {
        output[@"origin"] = origin;
    }
    
    if (output) {
        [self.touchesOutlet output:output];
    }
    /*
    if (gesture && view) {
        [self.touchesOutlet output:@{@"state": @(gesture.state),
                                  @"duration": @(duration),
                                  @"view":gesture.view,
                                  @"location": [NSValue wrapPoint:[gesture locationInView:view]],
                                  @"velocity": [NSValue wrapPoint:[gesture velocityInView:view]],
                                  @"origin":origin
                                  }];
    }
     */
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self.mainOutlet output:self.coldInlet.value];
    }
}

- (void)test
{
    self.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        NSLog(@"touch generator emitted value %@",outlet.value);
    };
}

@end
