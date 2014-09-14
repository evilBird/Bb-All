//
//  ViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "ViewController.h"
#import "BSDCanvas.h"

@interface ViewController ()

@property (nonatomic,strong)BSDCanvas *canvas;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.canvas = [[BSDCanvas alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.canvas];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
