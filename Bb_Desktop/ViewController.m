//
//  ViewController.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "BbCocoaPatchView+Touches.h"
#import "BbObject+Decoder.h"
#import "BbCocoaObjectView.h"
#import "BbCocoaPatchView.h"
#import "BbUI.h"
@interface ViewController ()
{
    CGPoint kFocusPoint;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    kFocusPoint = [NSView centerForFrame:self.view.bounds];
    [self testView];
}

- (void)testView
{
    NSString *mult_desc = [NSString stringWithFormat:@"#X obj 400 400 BbMultiply 8;\n"];
    BbCocoaPatchView *patchView = (BbCocoaPatchView *)self.view;
    [patchView addObjectAndViewWithText:mult_desc];
    NSString *add_desc = [NSString stringWithFormat:@"X obj 300 300 BbAdd 4;\n"];
    [patchView addObjectAndViewWithText:add_desc];
    //[patchView refreshEntityView];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

@end
