//
//  BSDViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDViewControllerRoot.h"
#import "BSDObjects.h"
typedef void(^PresentChildVCBlock)(void);
@interface BSDViewControllerRoot ()
{
    NSInteger kIsPresented;
}

@property (nonatomic,strong)UIViewController *viewController;
@property (nonatomic,strong)BSDView *view;
@property (nonatomic,strong)BSDRoute *routeToView;
@property (nonatomic,strong)PresentChildVCBlock presentChildBlock;

@end

@implementation BSDViewControllerRoot

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"root view controller";
    kIsPresented = NO;
    self.viewController = [[UIViewController alloc]init];
    self.viewController.view.backgroundColor = [UIColor whiteColor];
    self.routeToView = [[BSDRoute alloc]initWithArguments:@[@"view",@"anim",@"sel",@"set",@"get"]];
    [self.coldInlet forwardToPort:self.routeToView.hotInlet];
    self.view = [[BSDView alloc]initWithArguments:nil];
    [self.view.viewInlet input:self.viewController.view];
    [self.routeToView.outlets[0] connectToInlet:self.view.viewInlet];
    [self.routeToView.outlets[1] connectToInlet:self.view.animationInlet];
    [self.routeToView.outlets[2] connectToInlet:self.view.viewSelectorInlet];
    [self.routeToView.outlets[3] connectToInlet:self.view.setterInlet];
    [self.routeToView.outlets[4] connectToInlet:self.view.getterInlet];
    
    self.displayInlet = [[BSDInlet alloc]initHot];
    self.displayInlet.name = @"display";
    self.displayInlet.delegate = self;
    [self addPort:self.displayInlet];
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.displayInlet && [value isKindOfClass:[UIViewController class]]) {
        if ([self.viewController.childViewControllers containsObject:value]) {
            return;
        }
        /*
        if (kIsPresented) {
            [self.viewController presentViewController:value animated:YES completion:NULL];
        }else{
            __weak BSDViewControllerRoot *weakself = self;
            self.presentChildBlock = ^(void){
                [weakself.viewController presentViewController:value animated:YES completion:NULL];
            };
        }
         */
    }
}


- (void)calculateOutput
{
    NSNumber *hot = self.hotInlet.value;
    if (!hot || ![hot isKindOfClass:[NSNumber class]]) {
        return;
    }
    
    NSInteger val = hot.integerValue;
    if (val != kIsPresented) {
        if (val == 0) {
            [self requestDismissal];
        }else if (val == 1){
            [self requestPresentation];
        }
    }
}

- (void)requestPresentation
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kRequestPresentationNotificationChannel object:self.viewController];
    kIsPresented = YES;
}

- (void)requestDismissal
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kRequestDismissalNoficationChannel object:self.viewController];
    kIsPresented = NO;
}

- (void)tearDown
{
    if (kIsPresented) {
        [self requestDismissal];
    }
    
    [self.view tearDown];
    [self.routeToView tearDown];
    [super tearDown];
}

@end


@interface BSDViewController ()
{
    NSInteger kIsPresented;
}

@property (nonatomic,strong)UIViewController *viewController;
@property (nonatomic,strong)BSDView *view;
@property (nonatomic,strong)BSDRoute *routeToView;
@property (nonatomic,strong)BSDArrayPrepend *prependView;
@property (nonatomic,strong)BSDArrayPrepend *prependGet;

@end

@implementation BSDViewController

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"view controller";
    kIsPresented = NO;
    self.viewOutlet = [[BSDOutlet alloc]init];
    self.viewOutlet.name = @"view";
    [self addPort:self.viewOutlet];
    
    self.viewController = [[UIViewController alloc]init];
    self.viewController.view.backgroundColor = [UIColor redColor];
    self.routeToView = [[BSDRoute alloc]initWithArguments:@[@"view",@"anim",@"sel",@"set",@"get"]];
    [self.coldInlet forwardToPort:self.routeToView.hotInlet];
    self.view = [[BSDView alloc]initWithArguments:nil];
    [self.view.viewInlet input:self.viewController.view];
    [self.routeToView.outlets[0] connectToInlet:self.view.viewInlet];
    [self.routeToView.outlets[1] connectToInlet:self.view.animationInlet];
    [self.routeToView.outlets[2] connectToInlet:self.view.viewSelectorInlet];
    [self.routeToView.outlets[3] connectToInlet:self.view.setterInlet];
    [self.routeToView.outlets[4] connectToInlet:self.view.getterInlet];
    self.prependView = [[BSDArrayPrepend alloc]initWithArguments:@"view"];
    self.prependGet = [[BSDArrayPrepend alloc]initWithArguments:@"get"];
    [self.view.outlets[0] connectToInlet:self.prependView.hotInlet];
    [self.view.outlets[1] connectToInlet:self.prependGet.hotInlet];
    [self.prependView.outlets[0] forwardToPort:self.viewOutlet];
    [self.prependGet.outlets[0]forwardToPort:self.viewOutlet];
}

- (void)calculateOutput
{
    NSNumber *hot = self.hotInlet.value;
    if (!hot || ![hot isKindOfClass:[NSNumber class]]) {
        return;
    }
    
    NSInteger val = hot.integerValue;
    if (val != kIsPresented) {
        if (val == 0) {
            [self dismissViewController];
        }else if (val == 1){
            [self presentViewController];
        }
    }
}

- (void)dismissViewController
{
    UIViewController *presenter = self.viewController.presentingViewController;
    if (presenter) {
        [presenter dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)presentViewController
{
    UIViewController *presenter = self.viewController.presentingViewController;
    if (!presenter) {
        [self.mainOutlet output:self.viewController];
    }
}

@end
