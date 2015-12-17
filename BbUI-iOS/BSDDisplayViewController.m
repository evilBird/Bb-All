//
//  BSDDisplayViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDisplayViewController.h"
#import "BSDCanvasViewController.h"
#import "BSDDisplayManager.h"

@implementation BSDDisplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[BSDDisplayManager sharedInstance]addDisplayViewController:self];
}

- (IBAction)tapInCloseDisplayButton:(id)sender {
    
    [self.delegate hideDisplayViewController:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[BSDDisplayManager sharedInstance]removeDisplayViewController:self];
}

@end
