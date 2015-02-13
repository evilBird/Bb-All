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
#import "BbPatch.h"
@interface ViewController ()
{
    CGPoint kFocusPoint;
}

@property (nonatomic,strong)BbCocoaPatchView *patchView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.patchView = [[BbCocoaPatchView alloc]initWithEntity:[[BbPatch alloc]initWithArguments:nil]
                                                 viewDescription:nil
                                                    inParent:self.view];
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
    NSString *mult_desc = [NSString stringWithFormat:@"#X obj 50 50 BbMultiply 8;\n"];
    [self.patchView addObjectWithText:mult_desc];
    NSString *add_desc = [NSString stringWithFormat:@"X obj 25 25 BbAdd 4;\n"];
    [self.patchView addObjectWithText:add_desc];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

@end
