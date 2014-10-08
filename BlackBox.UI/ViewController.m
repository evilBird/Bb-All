//
//  ViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "ViewController.h"
#import "BSDCanvasViewController.h"
#import "BSDPatchCompiler.h"
@interface ViewController ()


@end

@implementation ViewController

#pragma mark - UIViewController overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    //BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    //[compiler test];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.presentedViewController) {
        [self presentCanvasForPatchWithName:nil];
    }
}

- (void)presentCanvasForPatchWithName:(NSString *)patchName
{
    BSDCanvasViewController *vc = [[BSDCanvasViewController alloc]initWithName:nil description:nil];
    [self presentViewController:vc animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
