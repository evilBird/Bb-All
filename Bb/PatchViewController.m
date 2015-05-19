//
//  ViewController.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//
#import "BbCocoaPatchView+Touches.h"
#import "BbObject+Decoder.h"
#import "BbCocoaObjectView.h"
#import "BbCocoaPatchView+Connections.h"
#import "BbUI.h"
#import "BbPatch.h"
#import "NSMutableString+Bb.h"
#import "PatchViewController.h"

@interface PatchViewController ()

@property (nonatomic,strong)BbCocoaPatchView *patchView;

@end

@implementation PatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedPatch:(BbPatch *)patch
{
    self.patch = patch;
    NSLog(@"represented object: %@",patch);
    if (self.patch && !self.patchView) {
        self.patchView = [BbCocoaPatchView patchViewWithPatch:self.patch inView:self.view];
        self.patchView.backgroundColor = [UIColor blueColor];
        [self.patchView autoCenterInSuperview];
#if TARGET_OS_IPHONE
        [self.view setNeedsDisplay];
        [self.view layoutIfNeeded];
#else
        [self.view setNeedsDisplay:YES];
#endif
        NSUInteger ancestors = [self.patch countAncestors];
        NSLog(@"ancestors: %@",@(ancestors));
    }
}

#if TARGET_OS_IPHONE == 0
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self setRepresentedPatch:representedObject];
}

#endif
 
@end
