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
#import "BSDDisplayViewController.h"
#import "BSDNestedPatchTableViewController.h"

@interface BSDCanvasViewController ()<UIScrollViewDelegate,UITableViewDelegate,BSDNestedPatchTableViewControllerDelegate,BSDDisplayViewControllerDelegate>
{
    NSString *desc;
    BOOL kCanvasWillClose;
}

@property (nonatomic,strong)UIViewController *displayViewController;
@property (strong, nonatomic) UIPopoverController *myPopoverController;
@property (nonatomic,strong)NSMutableDictionary *boxDictionary;
@property (nonatomic,strong)BSDCompiledPatch *compiledPatch;
@property (strong, nonatomic) IBOutlet BSDCanvasToolbarView *toolbarView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet BSDLogView *logView;
@property (strong, nonatomic) NSTimer *displayPreviewTimer;

@end

@implementation BSDCanvasViewController


- (BSDCanvas *)canvasFromPatchName:(NSString *)name
{
    NSString *description = [self.delegate savedPatchWithName:name sender:self];
    return [self canvasFromPatchDescription:description];
}

- (BSDCanvas *)canvasFromPatchDescription:(NSString *)description
{
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    BSDCanvas *canvas = [compiler restoreCanvasWithText:description];
    return canvas;
}

- (void)configureWithData:(id)data
{
    if ([data isKindOfClass:[NSString class]]){
        self.curentCanvas = [self canvasFromPatchName:data];
    }else if ([data isKindOfClass:[BSDCanvas class]]){
        self.curentCanvas = data;
    }else if ([data isKindOfClass:[BSDCompiledPatch class]]){
        self.curentCanvas = [(BSDCompiledPatch *)data canvas];
    }else if ([data isKindOfClass:[NSDictionary class]]){
        NSString *description = [data allValues].firstObject;
        self.curentCanvas = [self canvasFromPatchDescription:description];
    }
    
    self.currentPatchName = self.curentCanvas.name;
    self.title = self.currentPatchName;
    self.curentCanvas.delegate = self;
    self.canvases = [NSMutableArray arrayWithObject:self.curentCanvas];
    self.scrollView.contentSize = self.curentCanvas.bounds.size;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.curentCanvas.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.curentCanvas];
    self.scrollView.zoomScale = 0.9;
    self.toolbarView.delegate = self;
    [self.toolbarView setEditState:BSDCanvasEditStateDefault];
    [[NSNotificationCenter defaultCenter]addObserver:self.logView selector:@selector(handlePrintNotification:) name:kPrintNotificationChannel object:nil];
    self.displayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.curentCanvas loadBang];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleScreenDelegateNotification:) name:kScreenDelegateChannel
                                              object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.configuration) {
        id data  = self.configuration[@"data"];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self configureWithData:data];
            [self setConfiguration:nil];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.displayPreviewTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePreviewImage) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self.displayPreviewTimer invalidate];
    //self.displayPreviewTimer = nil;
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
                //[self showSavedPatchesTableView];
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
            //[self toggleCanvasVisibility];
            [self performSegueWithIdentifier:@"ShowDisplayView" sender:self];
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
    if ([self.delegate enableHomeButton:self]) {
        if ([self canvasHasUnsavedChanges:self.curentCanvas]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Close Canvas" message:[NSString stringWithFormat:@"Save changes to %@?",self.curentCanvas.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",@"Save as",@"Don't Save", nil];
            alert.tag = 2;
            [alert show];
        }else{
            [self.delegate popCanvas:self reload:NO];
        }
    }
}

- (BOOL)canvasHasUnsavedChanges:(BSDCanvas *)canvas
{
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    NSString *currentDescription = [compiler saveCanvas:canvas];
    if (!canvas.name) {
        return YES;
    }
    NSString *savedDescription = [self.delegate savedPatchWithName:canvas.name sender:self];
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
    for (UIView *sub in self.displayView.subviews) {
        [sub removeFromSuperview];
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *sp = [storyboard instantiateViewControllerWithIdentifier:@"NestedPatchNavController"];
        BSDNestedPatchTableViewController *npt = sp.viewControllers.firstObject;
        npt.patches = [self.delegate savedPatchesSender:self];
        npt.title = @"Library";
        npt.delegate = self;
        self.myPopoverController = [self popoverControllerWithContentViewController:sp];
        [self.myPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }else{
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }
}

- (void)updatePreviewImage
{
    if (!self.displayView) {
        return;
    }
    
    UIView *snap = [self.displayView snapshotViewAfterScreenUpdates:YES];
    if (self.displayPreviewImageView.subviews.count) {
        [self.displayPreviewImageView.subviews.firstObject removeFromSuperview];
    }
    [self.displayPreviewImageView addSubview:snap];
    
}
/*
- (void)showSavedPatchesTableView
{
    PopoverContentTableViewController *sp = [self savedPatchesTableViewController];
    [self presentViewController:sp animated:YES completion:NULL];
}
*/
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
    CGSize size = self.scrollView.contentSize;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size.width = self.view.bounds.size.width * 2;
        size.height = self.view.bounds.size.height * 2;
        self.scrollView.contentSize = size;
    }
    NSValue *sizeVal = [NSValue valueWithCGSize:size];
    NSLog(@"default size: %@",sizeVal);
    return size;
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

- (void)showCanvasForCompiledPatch:(BSDCompiledPatch *)patch
{
    self.childPatch = patch;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self performSegueWithIdentifier:@"ShowCanvasForChildPatch" sender:self];
    }];

}

- (UIView *)canvasScreen
{
    //UIView *view = self.displayView;
    return self.displayView;
}

- (void)handleScreenDelegateNotification:(NSNotification *)notification
{
    if (self.navigationController.viewControllers.lastObject == self) {
        BSDScreen *screen = notification.object;
        screen.delegate = self;
    }

}

- (void)canvas:(id)canvas editingStateChanged:(BSDCanvasEditState)editState
{
    [self.toolbarView setEditState:editState];
}

- (BOOL)enableHomeButtonInToolbarView:(id)sender
{
    return [self.delegate enableHomeButton:self];
}

#pragma mark - patch management

- (void)saveCurrentDescription
{
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    NSString *description = [compiler saveCanvas:self.curentCanvas];
    [self saveDescription:[NSString stringWithString:description] withName:self.curentCanvas.name];
}

- (void)saveDescription:(NSString *)description withName:(NSString *)name
{
    if (!name || !description) {
        return;
    }

    [self.delegate savePatchDescription:description withName:name sender:self];
    self.currentPatchName = name;
    self.curentCanvas.name = name;
    self.title = name;
}

- (NSString *)savedDescriptionWithName:(NSString *)name
{
    if (!name) {
        return nil;
    }
    return [self.delegate savedPatchWithName:name sender:self];
    
}

- (void)saveCanvas:(id)canvas description:(NSString *)description name:(NSString *)name
{
    
}

- (void)setCurrentCanvas:(id)canvas
{
    _curentCanvas = canvas;
}

- (void)loadDescriptionWithName:(NSString *)name
{
    if (!name) {
        return;
    }
    
    NSString *description = [self.delegate savedPatchWithName:name sender:self];
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
        self.title = name;
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
        self.currentPatchName = name;
        self.title = name;
        BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
        NSString *description = [compiler saveCanvas:self.curentCanvas];
        [self saveDescription:description withName:name];
        if (kCanvasWillClose) {
            
            [self.delegate popCanvas:self reload:NO];
            kCanvasWillClose = NO;
            
        }
    }else if (alertView.tag == 1 && buttonIndex == 1){
        NSString *name = [alertView textFieldAtIndex:0].text;
        if (name.length > 0) {
            [self.curentCanvas encapsulatedCopiedContentWithName:name];
        }
    }else if (alertView.tag == 2){
        
        if (buttonIndex == 1) {
            [self saveCurrentDescription];
            [self.delegate popCanvas:self reload:NO];
            kCanvasWillClose = NO;
        }else if (buttonIndex == 2){
            kCanvasWillClose = YES;
            [self showSavePatchAlertView];
        }else if (buttonIndex == 3){
            [self.delegate popCanvas:self reload:NO];
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
    [self.curentCanvas boxDidMove:nil];
}

#pragma mark - PopoverContentViewController Delegate

- (void)itemWasSelected:(NSString *)patchName
{
    NSArray *objects = @[@"bang box",@"number box",@"message box",@"object",@"inlet",@"outlet",@"canvas",@"comment",@"hslider"];
    if ([objects containsObject:patchName]) {
        CGPoint point = [self.curentCanvas optimalFocusPoint];
        [self contentTableViewControllerWasDismissed:nil];
        BSDCanvas *myCanvas = self.curentCanvas;
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
            [self.delegate addCanvasToStack:myCanvas];
        }else if ([patchName isEqualToString:@"comment"]){
            [myCanvas addCommentBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"hslider"]){
            [myCanvas addHSliderBoxAtPoint:point];
        }
        
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Utitlity methods

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

#pragma mark - BSDNestedPatchTableViewControllerDelegate
- (void)patchTableViewController:(id)sender selectedPatchWithName:(NSString *)patchName patchText:(NSString *)patchText
{
    [self.myPopoverController dismissPopoverAnimated:YES];
    self.myPopoverController = nil;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self loadDescriptionWithName:patchName];
    }];
}

- (void)patchTableViewController:(id)sender deletedItemAtPath:(NSString *)keyPath
{
    [self.delegate deleteItemAtPath:keyPath sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDisplayView"]) {
        id dest = segue.destinationViewController;
        if ([dest isKindOfClass:[BSDDisplayViewController class]]) {
            BSDDisplayViewController *d = (BSDDisplayViewController *)dest;
            d.delegate = self;
            [d.view insertSubview:self.displayView belowSubview:d.closeDisplayButton];
            self.displayView.backgroundColor = [UIColor whiteColor];
        }
    }else if ([segue.identifier isEqualToString:@"ShowCanvasForChildPatch"]){
        id dest = segue.destinationViewController;
        if ([dest isKindOfClass:[BSDCanvasViewController class]]) {
            BSDCanvasViewController *c = (BSDCanvasViewController *)dest;
            c.delegate = self.delegate;
            c.configuration = @{@"data":self.childPatch};
            
        }
    }
}

#pragma mark - BSDDisplayViewControllerDelegate
- (void)hideDisplayViewController:(id)sender
{
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }];
}


- (IBAction)clearLog:(id)sender {
    
    [self.logView clear];
}

- (IBAction)handleLogControlPan:(id)sender {
    
    UIPanGestureRecognizer *pan = sender;
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:pan.view];
        CGFloat constant = self.logViewHeight.constant;
        constant -= (translation.y);
        if (constant < 100) {
            constant = 100;
        }
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.logViewHeight.constant = constant;
                         }];
    }
}


@end
