//
//  BSDTouchView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDTouchView.h"
#import "NSValue+BSD.h"
@interface BSDTouchView ()

@property (nonatomic,strong)UIGestureRecognizer *recognizer;

@end

@implementation BSDTouchView

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"touch view";
    UIView *view = [self view];
    self.touchOutlet = [[BSDOutlet alloc]init];
    self.touchOutlet.name = @"touches";
    [self addPort:self.touchOutlet];

    self.recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleRecognizer:)];
    [view addGestureRecognizer:self.recognizer];
}

- (void)handleRecognizer:(UIPanGestureRecognizer *)sender
{
    CGPoint loc = [sender locationInView:[self view]];
    CGPoint velocity = [sender velocityInView:[self view]];
    NSInteger state = sender.state;
    
    NSDictionary *output = @{@"state":@(state),
                             @"location":[NSValue wrapPoint:loc],
                             @"velocity": [NSValue wrapPoint:velocity]
                             };
    
    [self.touchOutlet output:output.mutableCopy];
}



@end
