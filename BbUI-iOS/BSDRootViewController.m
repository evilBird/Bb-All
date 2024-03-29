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
#import "MyCloud.h"
#import "BSDDisplayManager.h"

static BOOL kCloudIsReady = NO;

@interface BSDRootViewController ()
{
    BOOL kInitialized;
}

@property (nonatomic,strong)NSMutableArray *canvasStack;

@end

@implementation BSDRootViewController

#pragma mark - UIViewController overrides

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloudIsReadyNotification:) name:@"com.birdSound.bb.cloudIsReadyNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleApplicationWillBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleApplicationWillForegroundNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [super viewDidLoad];
    kInitialized = NO;
}
- (void)testCloudDownload
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!kInitialized) {
        kInitialized = YES;
        [self showInitialCanvas];
        [BSDDisplayManager sharedInstance];
        NSLog(@"showing initial canvas");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInitialCanvas
{
    NSArray *children = self.childViewControllers;
    id first = children.firstObject;
    NSArray *grandChildren = [first viewControllers];
    id canvas = grandChildren.firstObject;
    if ([canvas isKindOfClass:[BSDCanvasViewController class]]){
        BSDCanvasViewController *c = (BSDCanvasViewController *)canvas;
        NSDictionary *data = @{@"untitled":[canvas emptyCanvasDescription]};
        [c setDelegate:self];
        [c configureWithData:data];
        if (!self.canvasStack) {
            self.canvasStack = [NSMutableArray array];
        }
        
        [self.canvasStack addObject:c];
    }
}


#pragma mark - BSDCanvasViewControllerDelegate

- (NSDictionary *)savedPatchesSender:(id)sender
{
    return [[BSDPatchManager sharedInstance]savedPatches];
}

- (BOOL)enableHomeButton:(id)sender
{
    return (self.canvasStack.count > 1) && (sender == self.canvasStack.lastObject);
}

- (void)addCanvasToStack:(id)sender
{
    NSLog(@"will add canvas, stack count: %@",@(self.canvasStack.count));

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id new = [storyboard instantiateViewControllerWithIdentifier:@"CanvasNavController"];
    id canvas = [new viewControllers].lastObject;
    if ([canvas isKindOfClass:[BSDCanvasViewController class]]) {
        NSDictionary *data = @{@"untitled":[canvas emptyCanvasDescription]};
        NSDictionary *config = @{@"data":data};
        [(BSDCanvasViewController *)canvas setConfiguration:config];
        [(BSDCanvasViewController *)canvas setDelegate:self];
        [self.canvasStack.lastObject presentViewController:new
                                                  animated:YES
                                                completion:NULL];
        if (![self.canvasStack containsObject:canvas]) {
            [self.canvasStack addObject:canvas];
        }
    }
    
    NSLog(@"added canvas, stack count: %@",@(self.canvasStack.count));
}

- (void)popCanvas:(id)sender
{
    [self popCanvas:sender reload:NO];
}

- (void)popCanvas:(id)sender reload:(BOOL)reload
{
    NSLog(@"popping canvas, stack count %@",@(self.canvasStack.count));
    [self.canvasStack removeLastObject];
    BSDCanvasViewController *top = self.canvasStack.lastObject;
    [top dismissViewControllerAnimated:YES completion:^{
        [[(BSDCanvasViewController *)sender curentCanvas] tearDown];
        NSLog(@"popped canvas, stack count %@",@(self.canvasStack.count));
    }];
}

- (NSString *)savedPatchWithName:(NSString *)name sender:(id)sender
{
    NSString *workingPath = nil;
    NSMutableArray *pathComponents = [name componentsSeparatedByString:@"."].mutableCopy;
    if ([pathComponents.lastObject isEqualToString:@"bb"]) {
        [pathComponents removeLastObject];
    }
    
    if (pathComponents.count) {
        workingPath = [NSDictionary pathWithComponents:pathComponents];
        [BSDPatchManager sharedInstance].workingPath = workingPath;
    }
    
    return [[BSDPatchManager sharedInstance]getPatchNamed:name];
}

- (void)savePatchDescription:(NSString *)description withName:(NSString *)name sender:(id)sender
{
    NSMutableArray *components = [name componentsSeparatedByString:@"."].mutableCopy;
    if ([components.lastObject isEqualToString:@"bb"]) {
        [components removeLastObject];
        name = [NSDictionary pathWithComponents:components];
    }
    
    [[BSDPatchManager sharedInstance]savePatchDescription:description withName:name];
}

- (void)deleteItemAtPath:(NSString *)path sender:(id)sender
{
    [[BSDPatchManager sharedInstance]deleteItemAtPath:path];
}

- (void)showCanvas:(BSDCanvas *)canvas sender:(id)sender
{
    
}

- (void)showCanvasForCompiledPatch:(BSDCompiledPatch *)compiledPatch sender:(id)sender
{
    
}

- (void)handleCloudIsReadyNotification:(NSNotification *)notification
{
    kCloudIsReady = YES;
    [[BSDPatchManager sharedInstance]update];
}

- (void)handleApplicationWillForegroundNotification:(NSNotification *)notification
{
    if (kCloudIsReady) {
        [[BSDPatchManager sharedInstance]update];
    }
}

- (void)handleApplicationWillBackgroundNotification:(NSNotification *)notification
{
    if (kCloudIsReady) {
        [[BSDPatchManager sharedInstance]update];
    }
}

@end
