//
//  BSDCanvasViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCanvasViewController.h"
#import "NSUserDefaults+HBVUtils.h"
#import "BSDPatchDescription.h"
#import "BSDPatchCompiler.h"
#import "BSDLogView.h"

@interface BSDCanvasViewController ()<UIScrollViewDelegate,UITableViewDelegate>
{
    NSString *desc;
    BOOL kCanvasWillClose;
}

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIViewController *displayViewController;
@property (nonatomic,strong)BSDCanvasToolbarView *toolbarView;
@property (strong, nonatomic) UIPopoverController *myPopoverController;
@property (nonatomic,strong)UIButton *closeDisplayViewButton;
@property (nonatomic,strong)BSDLogView *logView;
@property (nonatomic,strong)NSMutableDictionary *boxDictionary;

@end

@implementation BSDCanvasViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _currentPatchName = name;
        NSDictionary *patches = [NSUserDefaults valueForKey:@"descriptions"];
        desc = patches[name];
        if (!_currentPatchName) {
            _currentPatchName = @"untitled";
        }
    }
    
    return self;
}
- (instancetype)initWithName:(NSString *)name description:(NSString *)description
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _currentPatchName = name;
        desc = description;
        kCanvasWillClose = NO;
        if (!_currentPatchName) {
            _currentPatchName = @"untitled";
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleScreenDelegateNotification:) name:kScreenDelegateChannel
                                            object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.scrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.y = 104;
        self.scrollView = [[UIScrollView alloc]initWithFrame:frame];
        self.scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height * 3);
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 0.33;
        self.scrollView.maximumZoomScale = 2;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.displayViewController = [[UIViewController alloc]initWithNibName:nil bundle:nil];
        self.displayViewController.view.backgroundColor = [UIColor whiteColor];
        CGRect buttonRect = CGRectMake(8, 24, 44, 44);
        self.closeDisplayViewButton = [[UIButton alloc]initWithFrame:buttonRect];
        [self.closeDisplayViewButton setTitle:@"X" forState:UIControlStateNormal];
        [self.closeDisplayViewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.closeDisplayViewButton addTarget:self action:@selector(toggleCanvasVisibility) forControlEvents:UIControlEventTouchUpInside];
        [self.displayViewController.view addSubview:self.closeDisplayViewButton];
        
        if (!self.curentCanvas) {
            CGRect rect;
            rect.origin = self.scrollView.bounds.origin;
            rect.size = self.scrollView.contentSize;
            BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
            NSString *blank = [self emptyCanvasDescription];
            if (desc) {
                self.curentCanvas = [compiler restoreCanvasWithText:desc];
            }else{
                self.curentCanvas = [compiler restoreCanvasWithText:blank];
            }
            //self.curentCanvas = [compiler restoreCanvasWithText:test];
            self.curentCanvas.delegate = self;
            [self.scrollView addSubview:self.curentCanvas];
            [self.curentCanvas boxDidMove:nil];
            [self.view addSubview:self.scrollView];
            frame = self.view.bounds;
            frame.size.height = 104;
            self.toolbarView = [[BSDCanvasToolbarView alloc]initWithFrame:frame];
            self.toolbarView.delegate = self;
            [self.toolbarView setEditState:BSDCanvasEditStateDefault];
            self.toolbarView.titleLabel.text = self.currentPatchName;
            self.toolbarView.titleLabel.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
            [self.view addSubview:self.toolbarView];
            [self configureConstraints];
            frame = self.view.bounds;
            frame.size.height *= 0.15;
            frame.origin.y = CGRectGetMaxY(self.view.bounds) - frame.size.height;
            self.logView = [[BSDLogView alloc]initWithFrame:frame];
            [self.view addSubview:self.logView];
            //[self configureConstraintsForLogView:self.logView];
            self.canvases = [NSMutableArray array];
            [self.canvases addObject:self.curentCanvas];
        }
    }
}

- (void)configureConstraintsForLogView:(BSDLogView *)logview
{
    logview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *metrics = @{@"height":@(logview.bounds.size.height)};
    NSDictionary *views = NSDictionaryOfVariableBindings(logview);
    NSArray *constraints = nil;
    constraints  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[logview(150)]|"
                                                           options:0
                                                           metrics:metrics
                                                             views:views];
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[logview]|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self.view addConstraints:constraints];
    
}

- (void)configureConstraints
{
    self.toolbarView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_toolbarView);
    NSArray *constraints = nil;
    NSDictionary *metrics = @{@"toolbarHt":@(104)
                              };
    constraints = [NSLayoutConstraint
                   constraintsWithVisualFormat:@"H:|[_toolbarView]|"
                   options:0
                   metrics:nil
                   views:views];
    [self.view addConstraints:constraints];
    constraints  = [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:|[_toolbarView(toolbarHt@999)]"
                    options:0
                    metrics:metrics
                    views:views];
    [self.view addConstraints:constraints];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapInToolBar:(id)sender item:(id)item
{
    UIBarButtonItem *bbi = (UIBarButtonItem *)item;
    NSInteger tag = bbi.tag;
    switch (tag) {
        case 1:
            [self tapInHomeButton];
            break;
        case 2:
            [self showSavePatchAlertView];
            break;
        case 3:
        {
            if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
                [self showSavedPatchesPopoverFromBarButtonItem:bbi];
            }else if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
                [self showSavedPatchesTableView];
            }
        }
            break;
        case 4:
        {
            if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
                [self showAddBoxesPopoverFromBarButtonItem:bbi];
            }else if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
                [self showAddBoxesTableView];
            }
        }
            break;
        case 5:
            [self clearCanvas];
            break;
        case 6:
            [self tapInEditBarButtonItem:bbi];
            break;
        case 7:
            [self tapInDeleteBarButtonItem:bbi];
            break;
        case 8:
            [self tapInCopyBarButtonItem:bbi];
            break;
        case 9:
            [self tapInPasteBarButtonItem:bbi];
            break;
        case 10:
            [self encapsulateSelected];
            break;
        case 11:
            [self toggleCanvasVisibility];
            break;
        default:
            break;
    }

}

- (UIBarButtonItem *)barButtonItemForTag:(NSInteger)tag inToolbar:(BSDCanvasToolbarView *)toolbar
{
    return (UIBarButtonItem *)[toolbar viewWithTag:tag];
}

#pragma mark - handle bar button item taps

- (void)tapInHomeButton
{
    if ([self enableHomeButtonInToolbarView:nil]) {
        BSDCanvas *canvas = self.canvases.lastObject;
        if ([self canvasHasUnsavedChanges:canvas]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Close Canvas" message:[NSString stringWithFormat:@"Save changes to %@?",canvas.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",@"Save as",@"Don't Save", nil];
            alert.tag = 2;
            [alert show];
        }else{
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

- (BOOL)canvasHasUnsavedChanges:(BSDCanvas *)canvas
{
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    NSString *currentDescription = [compiler saveCanvas:canvas];
    NSDictionary *patches = [NSUserDefaults valueForKey:@"descriptions"];
    if (!canvas.name) {
        return YES;
    }
    NSString *savedDescription = patches[canvas.name];
    if (!savedDescription) {
        return YES;
    }
    BOOL result = [currentDescription isEqualToString:savedDescription];
    return 1 - result;
}

- (void)clearCanvas
{
    [self.curentCanvas clearCurrentPatch];
    self.curentCanvas.delegate = self;
    for (UIView *sub in self.displayViewController.view.subviews) {
        if (sub != self.closeDisplayViewButton) {
            [sub removeFromSuperview];
        }
    }
}

- (void)tapInEditBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.curentCanvas.editState == BSDCanvasEditStateDefault) {
        self.curentCanvas.editState = BSDCanvasEditStateEditing;
        self.toolbarView.editState = BSDCanvasEditStateEditing;
    }else{
        self.curentCanvas.editState = BSDCanvasEditStateDefault;
        self.toolbarView.editState = BSDCanvasEditStateDefault;
    }
}

- (void)tapInDeleteBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.curentCanvas.editState > 1) {
        [self.curentCanvas deleteSelectedContent];
        self.curentCanvas.editState = 1;
        self.toolbarView.editState = 1;
    }
}

- (void)tapInCopyBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.curentCanvas.editState > 1) {
        [self.curentCanvas copySelectedContent];
    }
}

- (void)tapInPasteBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.curentCanvas.editState == 3) {
        [self.curentCanvas pasteSelectedContent];
    }
}

- (void)encapsulateSelected
{
    if (self.curentCanvas.editState == 3) {
        [self showSaveAsPatchAlertView];
    }
}

- (void)toggleCanvasVisibility
{
    if (!self.presentedViewController) {
        if (self.closeDisplayViewButton.superview) {
            [self.closeDisplayViewButton removeFromSuperview];
            [self.displayViewController.view addSubview:self.closeDisplayViewButton];
        }
        [self presentViewController:self.displayViewController animated:YES completion:NULL];
    }else if (self.presentedViewController == self.displayViewController){
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)showSavePatchAlertView
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Save Patch"
                                                   message:@"Enter a name for this patch"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    if (self.currentPatchName) {
        [[alert textFieldAtIndex:0]setText:self.currentPatchName];
    }
    
    [alert show];
}

- (void)showSaveAsPatchAlertView
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Make abstraction"
                                                   message:@"Enter a name for this abstraction"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

- (void)showSavedPatchesPopoverFromBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.myPopoverController == nil) {
        PopoverContentTableViewController *sp = [self savedPatchesTableViewController];
        
        self.myPopoverController = [self popoverControllerWithContentViewController:sp];
        [self.myPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }else{
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }
}

- (void)showSavedPatchesTableView
{
    PopoverContentTableViewController *sp = [self savedPatchesTableViewController];
    [self presentViewController:sp animated:YES completion:NULL];
}

- (void)showAddBoxesTableView
{
    PopoverContentTableViewController *sp = [self addObjectsTableViewController];
    [self presentViewController:sp animated:YES completion:NULL];
}

- (void)showAddBoxesPopoverFromBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.myPopoverController == nil) {
        PopoverContentTableViewController *sp = [self addObjectsTableViewController];
        
        self.myPopoverController = [self popoverControllerWithContentViewController:sp];
        [self.myPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }else{
        
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }
}

#pragma mark - editing state management

- (CGSize)defaultCanvasSize
{
    return self.scrollView.contentSize;
}

- (NSString *)emptyCanvasDescriptionName:(NSString *)name
{
    CGSize size = [self defaultCanvasSize];
    NSString *entry = [NSString stringWithFormat:@"#N canvas 0 0 %@ %@ %@;\n",@(size.width),@(size.height),name];
    return entry;
}

- (NSString *)emptyCanvasDescription
{
    return [self emptyCanvasDescriptionName:@"untitled"];
}

- (void)newCanvasForPatch:(NSString *)patchName withBox:(BSDGraphBox *)graphBox
{
    NSDictionary *dictionary = [NSUserDefaults valueForKey:@"descriptions"];
    NSString *description = dictionary[patchName];
    BSDCanvasViewController *cvc = [[BSDCanvasViewController alloc]initWithName:patchName description:description];
    [self presentViewController:cvc animated:YES completion:NULL];
}

- (UIView *)canvasScreen
{
    UIView *view = self.displayViewController.view;
    return view;
}

- (UIView *)viewForCanvas:(id)canvas
{
    return self.displayViewController.view;
}

- (void)handleScreenDelegateNotification:(NSNotification *)notification
{
    if (!self.presentedViewController || ![self.presentedViewController isKindOfClass:[BSDCanvasViewController class]]) {
        BSDScreen *screen = notification.object;
        screen.delegate = self;
    }
}

- (void)canvas:(id)canvas editingStateChanged:(BSDCanvasEditState)editState
{
    [self.toolbarView setEditState:editState];
}

- (void)presentCanvasForPatchWithName:(NSString *)patchName
{
    NSString *description = nil;
    
    if ([patchName isEqualToString:@"untitled"]) {
        description = [self emptyCanvasDescription];
    }else{
        description = [self savedDescriptionWithName:patchName];
    }
    
    BSDCanvasViewController *vc = [[BSDCanvasViewController alloc]initWithName:patchName description:description];
    [self presentViewController:vc animated:YES completion:NULL];
}

- (BOOL)enableHomeButtonInToolbarView:(id)sender
{
    if ([self.presentingViewController isKindOfClass:[BSDCanvasViewController class]]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - patch management

- (void)setCurrentPatchName:(NSString *)currentPatchName
{
    _currentPatchName = currentPatchName;
    self.toolbarView.titleLabel.text = currentPatchName;
}

- (void)saveCurrentDescription
{
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    self.curentCanvas.name = self.currentPatchName;
    NSString *description = [compiler saveCanvas:self.curentCanvas];//compiler.stringOutlet.value;
    [self saveDescription:[NSString stringWithString:description] withName:self.currentPatchName];
}

- (void)saveDescription:(NSString *)description withName:(NSString *)name
{
    if (!name || !description) {
        return;
    }
    
    NSDictionary *descriptions = [NSUserDefaults valueForKey:@"descriptions"];
    if (!descriptions) {
        descriptions = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *copy = descriptions.mutableCopy;
    copy[name] = description;
    [NSUserDefaults setUserValue:[NSDictionary dictionaryWithDictionary:copy] forKey:@"descriptions"];
    self.currentPatchName = name;
    self.curentCanvas.name = name;
    
    [self.delegate syncPatch:description withName:name];
}

- (NSString *)savedDescriptionWithName:(NSString *)name
{
    if (!name) {
        return nil;
    }
    
    NSDictionary *descriptions = [NSUserDefaults valueForKey:@"descriptions"];
    if (!descriptions || ![descriptions.allKeys containsObject:name]) {
        return nil;
    }
    
    NSString *description = [descriptions valueForKey:name];
    return [NSString stringWithString:description];
    
}

- (void)saveCanvas:(id)canvas description:(NSString *)description name:(NSString *)name
{
    
}

- (void)setCurrentCanvas:(id)canvas
{
    if (![self.canvases containsObject:canvas]) {
        [self.canvases addObject:canvas];
    }
    
    self.curentCanvas = canvas;
}

- (void)loadDescriptionWithName:(NSString *)name
{
    if (!name) {
        return;
    }
    NSDictionary *descriptions = [NSUserDefaults valueForKey:@"descriptions"];
    if (!descriptions) {
        descriptions = [NSDictionary dictionary];
    }
    
    NSString *description = [descriptions valueForKey:name];
    if (description) {
        NSString *toLoad = [NSString stringWithString:description];
        [self.curentCanvas tearDown];
        [self.curentCanvas removeFromSuperview];
        [self clearCanvas];
        self.curentCanvas = nil;
        BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
        self.curentCanvas = [compiler restoreCanvasWithText:toLoad];
        self.curentCanvas.delegate = self;
        self.curentCanvas.name = name;
        [self.scrollView addSubview:self.curentCanvas];
        self.currentPatchName = name;
        [self.curentCanvas loadBang];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0 && buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        if (!name) {
            return;
        }
        self.curentCanvas.name = name;
        BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
        NSString *description = [compiler saveCanvas:self.curentCanvas];//[compiler.stringOutlet value];
        [self saveDescription:description withName:name];
        if (kCanvasWillClose) {
            [self.curentCanvas clearCurrentPatch];
            self.canvases = nil;
            self.curentCanvas = nil;
            __weak BSDCanvasViewController *weakself = self;
            [self.presentingViewController dismissViewControllerAnimated:YES
                                                              completion:^{
                                                                  kCanvasWillClose = NO;
                                                                  BSDCanvasViewController *parent = (BSDCanvasViewController *)weakself.presentingViewController;
                                                                  [parent saveCurrentDescription];
                                                                  [parent loadDescriptionWithName:parent.currentPatchName];
                                                              }];
        }
    }else if (alertView.tag == 1 && buttonIndex == 1){
        NSString *name = [alertView textFieldAtIndex:0].text;
        if (name.length > 0) {
            [self.curentCanvas encapsulatedCopiedContentWithName:name];
        }
    }else if (alertView.tag == 2){
        
        if (buttonIndex == 1) {
            [self saveCurrentDescription];
            [self.curentCanvas clearCurrentPatch];
            self.curentCanvas = nil;
            self.canvases = nil;
            __weak BSDCanvasViewController *weakself = self;
            [self.presentingViewController dismissViewControllerAnimated:YES
                                                              completion:^{
                                                                  kCanvasWillClose = NO;
                                                                  BSDCanvasViewController *parent = (BSDCanvasViewController *)weakself.presentingViewController;
                                                                  [parent saveCurrentDescription];
                                                                  [parent loadDescriptionWithName:parent.currentPatchName];
                                                              }];
        }else if (buttonIndex == 2){
            kCanvasWillClose = YES;
            [self showSavePatchAlertView];
        }else if (buttonIndex == 3){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.curentCanvas;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"scroll view did zoom");
}

#pragma mark - PopoverContentViewController Delegate

- (void)itemWasSelected:(NSString *)patchName
{
    NSArray *objects = @[@"bang box",@"number box",@"message box",@"object",@"inlet",@"outlet",@"canvas",@"comment",@"hslider"];
    if ([objects containsObject:patchName]) {
        CGPoint point = [self.curentCanvas optimalFocusPoint];
        [self contentTableViewControllerWasDismissed:nil];
        
        BSDCanvas *myCanvas = nil;
        for (UIView *subview in self.curentCanvas.subviews) {
            if ([subview isKindOfClass:[BSDCanvas class]]) {
                myCanvas = (BSDCanvas *)subview;
            }
        }
        
        if (myCanvas == nil) {
            myCanvas = self.curentCanvas;
            myCanvas.delegate = self;
        }else{
            
        }
        
        if ([patchName isEqualToString:@"bang box"]) {
            [myCanvas addBangBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"number box"]){
            [myCanvas addNumberBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"message box"]){
            [myCanvas addMessageBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"inlet"]){
            [myCanvas addInletBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"outlet"]){
            [myCanvas addOutletBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"object"]){
            [myCanvas addGraphBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"canvas"]){
            [self presentCanvasForPatchWithName:@"untitled"];
        }else if ([patchName isEqualToString:@"comment"]){
            [myCanvas addCommentBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"hslider"]){
            [myCanvas addHSliderBoxAtPoint:point];
        }
        
        
    }else{
        [self contentTableViewControllerWasDismissed:nil];
        [self loadDescriptionWithName:patchName];
    }
    
}

- (void)contentTableViewControllerWasDismissed:(id)sender
{
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }else if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)itemWasDeleted:(NSString *)itemName
{
    if (!itemName) {
        return;
    }
    
    NSDictionary *savedPatches = [NSUserDefaults valueForKey:@"descriptions"];
    if (savedPatches && [savedPatches.allKeys containsObject:itemName]) {
        NSMutableDictionary *copy = [savedPatches mutableCopy];
        [copy removeObjectForKey:itemName];
        [NSUserDefaults setUserValue:[NSDictionary dictionaryWithDictionary:copy] forKey:@"descriptions"];
        //[self.delegate deleteSyncedPatchWithName:itemName];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Utitlity methods

- (PopoverContentTableViewController *)savedPatchesTableViewController
{
    PopoverContentTableViewController *sptvc = [[PopoverContentTableViewController alloc]initWithStyle:UITableViewStylePlain];
    sptvc.delegate = self;
    sptvc.title = @"Load Patch";
    NSDictionary *savedPatches = [NSUserDefaults valueForKey:@"descriptions"];
    //NSArray *savedPatches = [self.delegate patchList];
    if (savedPatches) {
        NSMutableArray *arr = [savedPatches.allKeys mutableCopy];
        sptvc.itemNames = [arr sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        sptvc.editEnabled = YES;
    }else{
        sptvc.itemNames = @[@"No saved patches"];
    }
    
    return sptvc;
}

- (PopoverContentTableViewController *)addObjectsTableViewController
{
    PopoverContentTableViewController *tvc = [[PopoverContentTableViewController alloc]initWithStyle:UITableViewStylePlain];
    tvc.delegate = self;
    tvc.title = @"Insert Box";
    tvc.editEnabled = NO;
    tvc.itemNames = @[@"bang box",@"number box",@"message box",@"inlet",@"outlet",@"object",@"canvas",@"comment",@"hslider"];
    return tvc;
}

- (UIPopoverController *)popoverControllerWithContentViewController:(UIViewController *)viewController
{
    UIPopoverController *poc = [[UIPopoverController alloc]initWithContentViewController:viewController];
    poc.delegate = self;
    return poc;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.myPopoverController) {
        self.myPopoverController = nil;
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
