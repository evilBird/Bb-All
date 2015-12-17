//
//  ViewController.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "BbCanvasView.h"
#import "UIView+Layout.h"
#import "BbDummyView.h"
#import "BbTouchHandler.h"

@interface ViewController () <BbTouchHandlerDelegate,BbTouchHandlerDataSource>

@property (nonatomic,strong)                BbCanvasView         *canvasView;
@property (nonatomic,strong)                BbTouchHandler      *touchHandler;
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
    [self setupCanvasViewAndTouchHandler];
    [self setupEditToggle];
    [self.view layoutIfNeeded];
}

- (void)setupCanvasViewAndTouchHandler
{
    self.canvasView = [BbCanvasView new];
    self.canvasView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.canvasView];
    [self.view addConstraints:[self.canvasView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    self.touchHandler = [[BbTouchHandler alloc]initWithCanvasView:self.canvasView delegate:self datasouce:self];
}

- (void)setupEditToggle
{
    self.toggleEditStateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.toggleEditStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.toggleEditStateButton aboveSubview:self.canvasView];
    [self.toggleEditStateButton setTitle:@"Not Editing" forState:UIControlStateNormal];
    [self.toggleEditStateButton setTitle:@"Editing" forState:UIControlStateSelected];
    [self.toggleEditStateButton addTarget:self action:@selector(toggleEditingState:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addConstraint:[self.toggleEditStateButton pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.view withInset:20]];
    [self.view addConstraint:[self.toggleEditStateButton pinEdge:LayoutEdge_Left toEdge:LayoutEdge_Left ofView:self.view withInset:20]];

}

- (void)setupDummyViews
{
    NSArray *classNames = @[@"object",@"message",@"number",@"slider",@"bang"];
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    CGFloat uw = (u_int32_t)(w*0.8);
    CGFloat uh = (u_int32_t)(h*0.8);
    NSUInteger tag = 0;
    self.view.tag = tag++;
    for ( NSString *className in classNames ) {
        BbDummyView *dummyView = [[BbDummyView alloc]initWithDummyClass:className];
        dummyView.tag = tag++;
        [self.canvasView addSubview:dummyView];
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

#pragma mark - Touch handler delegate

#pragma mark - Touch handler datasource
- (BOOL)canvasIsEditing:(id)sender
{
    return self.isEditing;
}

- (BOOL)canvasHasActiveOutlet:(id)sender
{
    return NO;
}

@end
