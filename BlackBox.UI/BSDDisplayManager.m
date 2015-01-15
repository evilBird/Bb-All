//
//  BSDDisplayManager.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDDisplayManager.h"
#import "BSDViewControllerRoot.h"
#import "BSDDisplayViewController.h"
#import "PureLayout.h"

typedef void (^ManageDisplayBlock)(void);

@interface BSDDisplayManager ()

@property (nonatomic,strong)NSMutableArray *viewControllers;
@property (nonatomic,strong)ManageDisplayBlock queuedActionBlock;
@property (nonatomic,strong)NSMutableArray *actionQueue;

@end

@implementation BSDDisplayManager

+ (BSDDisplayManager *)sharedInstance
{
    static BSDDisplayManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BSDDisplayManager alloc]init];
    });
    return _sharedInstance;
}

- (void)addDisplayViewController:(UIViewController *)viewController
{
    if (!self.viewControllers) {
        self.viewControllers = [NSMutableArray array];
    }
    if ([self.viewControllers containsObject:viewController]) {
        return;
    }
    
    [self.viewControllers addObject:viewController];
    if (self.queuedActionBlock != NULL) {
        self.queuedActionBlock();
    }
}

- (void)removeDisplayViewController:(UIViewController *)viewController
{
    if (!self.viewControllers || ![self.viewControllers containsObject:viewController]) {
        return;
    }
    
    [self.viewControllers removeObject:viewController];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handlePresentationRequestNotification:) name:kRequestPresentationNotificationChannel object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDismissalRequestNotification:) name:kRequestDismissalNoficationChannel object:nil];
    }
    
    return self;
}

- (void)handlePresentationRequestNotification:(NSNotification *)notification
{
    UIViewController *viewController = notification.object;
    ManageDisplayBlock block = [self presentBlockForViewController:viewController];
    if (self.viewControllers.count > 0) {
        self.queuedActionBlock = nil;
        block();
    }else{
        self.queuedActionBlock = [block copy];
    }
}

- (void)handleDismissalRequestNotification:(NSNotification *)notification
{
    UIViewController *viewController = notification.object;
    ManageDisplayBlock block = [self dismissBlockForViewController:viewController];
    if (self.viewControllers.count > 0) {
        self.queuedActionBlock = NULL;
        block();
    }else{
        self.queuedActionBlock = [block copy];
    }
}

- (void)addBlockToActionQueue:(ManageDisplayBlock)block
{
    if (!self.actionQueue) {
        self.actionQueue = [NSMutableArray array];
    }
    
    [self.actionQueue addObject:[block copy]];
}

- (ManageDisplayBlock)dismissBlockForViewController:(UIViewController *)viewController
{
    return ^(void){
        UIViewController *presenter = viewController.presentingViewController;
        if (presenter) {
            [presenter dismissViewControllerAnimated:NO completion:NULL];
        }
    };
}

- (ManageDisplayBlock)presentBlockForViewController:(UIViewController *)viewController
{
    __weak BSDDisplayManager *weakself = self;
    return ^(void){
        UIViewController *presenter = weakself.viewControllers.lastObject;
        if ([presenter isKindOfClass:[BSDDisplayViewController class]]) {
            UIButton *button = [(BSDDisplayViewController *)presenter closeDisplayButton];
            [button removeFromSuperview];
            [viewController.view addSubview:button];
            [button autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
            [button autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
        }
        
        if (!presenter.presentedViewController) {
            [presenter presentViewController:viewController animated:YES completion:NULL];
        }
    };
}

@end
