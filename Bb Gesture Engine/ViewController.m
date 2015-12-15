//
//  ViewController.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "BbTouchView.h"
#import "UIView+Layout.h"

@interface ViewController ()

@property (nonatomic,strong)        BbTouchView         *touchView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.touchView = [BbTouchView new];
    self.touchView.translatesAutoresizingMaskIntoConstraints = NO;
    self.touchView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.touchView];
    [self.view addConstraints:[self.touchView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    [self.view layoutIfNeeded];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
