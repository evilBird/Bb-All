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
#import "BbBasicTouchHandler.h"
#import "BbDummyView.h"

@interface ViewController () <BbBasicTouchHandlerDelegate>

@property (nonatomic,strong)                BbTouchView         *touchView;
@property (nonatomic,strong)                BbBasicTouchHandler *touchHandler;
@property (nonatomic,strong)                UIButton            *toggleEditStateButton;
@property (nonatomic,getter=isEditing)      BOOL                editing;
@property (nonatomic,strong)                NSArray             *dummyViews;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)setupUI
{
    self.touchView = [BbTouchView new];
    self.touchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.touchView];
    [self.view addConstraints:[self.touchView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    self.touchHandler = [[BbBasicTouchHandler alloc]initWithTouchView:self.touchView delegate:self];
    self.toggleEditStateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.toggleEditStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.toggleEditStateButton aboveSubview:self.touchView];
    [self.toggleEditStateButton setTitle:@"Not Editing" forState:UIControlStateNormal];
    [self.toggleEditStateButton setTitle:@"Editing" forState:UIControlStateSelected];
    [self.toggleEditStateButton addTarget:self action:@selector(toggleEditingState:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addConstraint:[self.toggleEditStateButton pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.view withInset:20]];
    [self.view addConstraint:[self.toggleEditStateButton pinEdge:LayoutEdge_Left toEdge:LayoutEdge_Left ofView:self.view withInset:20]];
    [self addDummyViewsWithClassNames:@[@"object",@"message",@"number",@"slider",@"bang"]];
    [self.view layoutIfNeeded];
}

- (void)addDummyViewsWithClassNames:(NSArray *)classNames
{
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    CGFloat uw = (u_int32_t)(w);
    CGFloat uh = (u_int32_t)(h);
    for ( NSString *className in classNames ) {
        BbDummyView *dummyView = [[BbDummyView alloc]initWithDummyClass:className];
        [self.view addSubview:dummyView];
        CGFloat offsetX = ((CGFloat)arc4random_uniform(uw) - w/2.0);
        CGFloat offsetY = ((CGFloat)arc4random_uniform(uh) - h/2.0);
        [self.view addConstraint:[dummyView alignCenterXToSuperOffset:offsetX]];
        [self.view addConstraint:[dummyView alignCenterYToSuperOffset:offsetY]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target/Action
- (void)toggleEditingState:(id)sender
{
    UIButton *button = sender;
    if ( self.isEditing ){
        self.editing = NO;
    }else{
        self.editing = YES;
    }
    
    button.selected = self.isEditing;
}

#pragma mark - Basic touch handler delegate

- (void)touchHandler:(id)sender recognizedGestureWithTag:(NSString *)gestureTag
{
    NSLog(@"GESTURE RECOGNIZED: %@",gestureTag);
}

- (void)touchHandler:(id)sender possibleGesturesWithTags:(NSArray *)gestureTags
{
    NSString *tags = [gestureTags componentsJoinedByString:@", "];
    NSLog(@"POSSIBLE GESTURES: %@",tags);
}

- (void)touchHandlerCancelTouchesInView:(id)sender
{
    [self.touchView gestureWasRecognized];
}
@end
