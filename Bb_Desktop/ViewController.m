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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testView];
    // Do any additional setup after loading the view.
}
- (void)testView
{
    NSString *toParse = [NSString stringWithFormat:@"#X obj 400 400 BbMultiply 8;\n"];
    BbCocoaPatchView *patchView = (BbCocoaPatchView *)self.view;
    [patchView addObjectAndViewWithText:toParse];
    [self.view setNeedsLayout:YES];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

@end
