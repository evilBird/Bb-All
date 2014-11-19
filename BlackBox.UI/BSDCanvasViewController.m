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

//@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIViewController *displayViewController;
//@property (nonatomic,strong)BSDCanvasToolbarView *toolbarView;
@property (strong, nonatomic) UIPopoverController *myPopoverController;
@property (nonatomic,strong)UIButton *closeDisplayViewButton;
//@property (nonatomic,strong)BSDLogView *logView;
@property (nonatomic,strong)NSMutableDictionary *boxDictionary;
@property (nonatomic,strong)BSDCompiledPatch *compiledPatch;
@property (strong, nonatomic) IBOutlet BSDCanvasToolbarView *toolbarView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet BSDLogView *logView;

@end

@implementation BSDCanvasViewController

- (instancetype)initWithCompiledPatch:(BSDCompiledPatch *)compiledPatch
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _compiledPatch = compiledPatch;
        _curentCanvas = compiledPatch.canvas;
        _currentPatchName = _curentCanvas.name;
    }
    
    return self;
}

- (instancetype)initWithCanvas:(BSDCanvas *)canvas
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _currentPatchName = canvas.name;
        self.curentCanvas = canvas;
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _currentPatchName = name;
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

- (void)configureWithName:(NSString *)name
                     data:(id)data
                 delegate:(id<BSDCanvasViewControllerDelegate>)delegate
{
    self.delegate = delegate;
    self.currentPatchName = name;
    self.title = name;
    self.curentCanvas = nil;
    
    if (data == nil) {
        self.curentCanvas = [self canvasFromPatchName:name];
    }else if ([data isKindOfClass:[NSString class]]){
        self.curentCanvas = [self canvasFromPatchDescription:data];
    }else if ([data isKindOfClass:[BSDCanvas class]]){
        self.curentCanvas = data;
    }else if ([data isKindOfClass:[BSDCompiledPatch class]]){
        self.curentCanvas = [(BSDCompiledPatch *)data canvas];
    }
    
    self.curentCanvas.name = name;
    self.curentCanvas.delegate = self;
    self.canvases = [NSMutableArray arrayWithObject:self.curentCanvas];
    self.scrollView.contentSize = self.curentCanvas.bounds.size;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.curentCanvas.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.curentCanvas];
    self.toolbarView.delegate = self;
    [self.toolbarView setEditState:BSDCanvasEditStateDefault];
    [[NSNotificationCenter defaultCenter]addObserver:self.logView selector:@selector(handlePrintNotification:) name:kPrintNotificationChannel object:nil];
    self.displayView = [[UIView alloc]initWithFrame:self.view.bounds];
}

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
    self.toolbarView.delegate = self;
    [self.toolbarView setEditState:BSDCanvasEditStateDefault];
    [[NSNotificationCenter defaultCenter]addObserver:self.logView selector:@selector(handlePrintNotification:) name:kPrintNotificationChannel object:nil];
    self.displayView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.curentCanvas loadBang];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)newCanvasForPatch:(NSString *)patchName withBox:(BSDGraphBox *)graphBox
{
    NSString *description = [self.delegate savedPatchWithName:patchName sender:self];
    BSDCanvasViewController *cvc = [[BSDCanvasViewController alloc]initWithName:patchName description:description];
    [self presentViewController:cvc animated:YES completion:NULL];
}

- (void)showCanvas:(BSDCanvas *)canvas
{
    BSDCanvasViewController *cvc = [[BSDCanvasViewController alloc]initWithCanvas:canvas];
    cvc.delegate = self.delegate;
    [self presentViewController:cvc animated:YES completion:NULL];
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
    UIView *view = self.displayView;
    return self.displayView;
}

- (UIView *)viewForCanvas:(id)canvas
{
    return self.displayViewController.view;
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
    return [self.delegate enableHomeButton:self];
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
    //NSLog(@"scroll view did zoom");
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
    NSDictionary *savedPatches = [self.delegate savedPatchesSender:self];
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

/*
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.compiledPatch) {
        NSDictionary *patches = [NSUserDefaults valueForKey:@"descriptions"];
        desc = patches[_currentPatchName];
        [self.compiledPatch reloadPatch:desc];
    }
}
*/
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
