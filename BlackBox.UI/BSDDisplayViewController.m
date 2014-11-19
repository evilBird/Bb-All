//
//  BSDDisplayViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDisplayViewController.h"
#import "BSDCanvasViewController.h"

@implementation BSDDisplayViewController

- (IBAction)tapInCloseDisplayButton:(id)sender {
    
    [self.delegate hideDisplayViewController:self];
}

@end
