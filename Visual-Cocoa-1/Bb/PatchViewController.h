//
//  ViewController.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define VCViewController        UIViewController
#else
#import <AppKit/AppKit.h>
#define VCViewController        NSViewController
#endif

@class BbPatch;
@interface PatchViewController : VCViewController

@property (nonatomic,strong)BbPatch *patch;

- (void)setRepresentedPatch:(BbPatch *)patch;

@end

