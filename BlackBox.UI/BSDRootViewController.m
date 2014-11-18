//
//  ViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDRootViewController.h"
#import "BSDCanvasViewController.h"
#import "BSDPatchCompiler.h"
#import "NSUserDefaults+HBVUtils.h"
#import <MessageUI/MessageUI.h>
#import "BSDPatchManager.h"

@interface BSDRootViewController ()



@end

@implementation BSDRootViewController

#pragma mark - UIViewController overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.presentedViewController) {
        [self presentCanvasForPatchWithName:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BSDCanvasViewControllerDelegate

- (NSDictionary *)savedPatchesSender:(id)sender
{
    return [[BSDPatchManager sharedInstance]savedPatches];
}

- (NSString *)savedPatchWithName:(NSString *)name sender:(id)sender
{
    return [[BSDPatchManager sharedInstance]getPatchNamed:name];
}

- (void)savePatchDescription:(NSString *)description withName:(NSString *)name sender:(id)sender
{
    [[BSDPatchManager sharedInstance]savePatchDescription:description withName:name];
}

- (void)deleteItemAtPath:(NSString *)path sender:(id)sender
{
    [[BSDPatchManager sharedInstance]deleteItemAtPath:path];
}

- (void)presentCanvasForPatchWithName:(NSString *)patchName
{
    BSDCanvasViewController *vc = [[BSDCanvasViewController alloc]initWithName:nil description:nil];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:NULL];
}



@end
