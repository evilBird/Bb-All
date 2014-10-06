//
//  BSDCanvasViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCanvasViewController.h"
#import "NSUserDefaults+HBVUtils.h"

@interface BSDCanvasViewController ()<UIScrollViewDelegate,UITableViewDelegate>
{
    NSString *desc;
}

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIViewController *displayViewController;
@property (nonatomic,strong)BSDCanvasToolbarView *toolbarView;
@property (strong, nonatomic) UIPopoverController *myPopoverController;
@property (nonatomic,strong)UIButton *closeDisplayViewButton;

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
- (instancetype)initWithName:(NSString *)name description:(NSString *)description
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _currentPatchName = name;
        desc = description;
        if (!_currentPatchName) {
            _currentPatchName = @"untitled";
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.scrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.y = 104;
        self.scrollView = [[UIScrollView alloc]initWithFrame:frame];
        self.scrollView.contentSize = CGSizeMake(frame.size.width * 2, frame.size.height * 2);
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 1;
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
        
        if (!self.canvas) {
            CGRect rect;
            rect.origin = self.scrollView.bounds.origin;
            rect.size = self.scrollView.contentSize;
            if (desc) {
                self.canvas = [[BSDCanvas alloc]initWithDescription:desc];
            }else{
                self.canvas = [[BSDCanvas alloc]initWithFrame:frame];
            }
            self.canvas.delegate = self;
            [self.scrollView addSubview:self.canvas];
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
        }
    }
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
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)clearCanvas
{
    [self.canvas clearCurrentPatch];
    for (UIView *sub in self.displayViewController.view.subviews) {
        if (sub != self.closeDisplayViewButton) {
            [sub removeFromSuperview];
        }
    }
}

- (void)tapInEditBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.canvas.editState == BSDCanvasEditStateDefault) {
        self.canvas.editState = BSDCanvasEditStateEditing;
        self.toolbarView.editState = BSDCanvasEditStateEditing;
    }else{
        self.canvas.editState = BSDCanvasEditStateDefault;
        self.toolbarView.editState = BSDCanvasEditStateDefault;
    }
}

- (void)tapInDeleteBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.canvas.editState > 1) {
        [self.canvas deleteSelectedContent];
        self.canvas.editState = 1;
        self.toolbarView.editState = 1;
    }
}

- (void)tapInCopyBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.canvas.editState > 1) {
        [self.canvas copySelectedContent];
    }
}

- (void)tapInPasteBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.canvas.editState == 3) {
        [self.canvas pasteSelectedContent];
    }
}

- (void)encapsulateSelected
{
    if (self.canvas.editState == 3) {
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

- (UIView *)viewForCanvas:(id)canvas
{
    return self.displayViewController.view;
}

- (void)canvas:(id)canvas editingStateChanged:(BSDCanvasEditState)editState
{
    [self.toolbarView setEditState:editState];
}

- (void)presentCanvasForPatchWithName:(NSString *)patchName
{
    NSString *description = [self savedDescriptionWithName:patchName];
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
    NSString *description = [self.canvas stringDescription];
    [self saveDescription:description withName:self.currentPatchName];
}

- (void)saveDescription:(NSString *)description withName:(NSString *)name
{
    if (!name) {
        return;
    }
    
    NSDictionary *descriptions = [NSUserDefaults valueForKey:@"descriptions"];
    if (!descriptions) {
        descriptions = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *copy = descriptions.mutableCopy;
    copy[name] = description;
    [NSUserDefaults setUserValue:[NSDictionary dictionaryWithDictionary:copy] forKey:@"descriptions"];
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
        [self.canvas loadPatchWithDescription:toLoad];
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
        NSString *description = [self.canvas stringDescription];
        [self saveDescription:description withName:name];
    }else if (alertView.tag == 1 && buttonIndex == 1){
        NSString *name = [alertView textFieldAtIndex:0].text;
        if (name.length > 0) {
            [self.canvas encapsulatedCopiedContentWithName:name];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.canvas;
}

#pragma mark - PopoverContentViewController Delegate

- (void)itemWasSelected:(NSString *)patchName
{
    NSArray *objects = @[@"bang box",@"number box",@"message box",@"object",@"inlet",@"outlet",@"canvas",@"comment"];
    if ([objects containsObject:patchName]) {
        CGPoint point = [self.canvas optimalFocusPoint];
        [self contentTableViewControllerWasDismissed:nil];
        if ([patchName isEqualToString:@"bang box"]) {
            [self.canvas addBangBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"number box"]){
            [self.canvas addNumberBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"message box"]){
            [self.canvas addMessageBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"inlet"]){
            [self.canvas addInletBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"outlet"]){
            [self.canvas addOutletBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"object"]){
            [self.canvas addGraphBoxAtPoint:point];
        }else if ([patchName isEqualToString:@"canvas"]){
            [self presentCanvasForPatchWithName:@"new patch"];
        }else if ([patchName isEqualToString:@"comment"]){
            [self.canvas addCommentBoxAtPoint:point];
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
    tvc.itemNames = @[@"bang box",@"number box",@"message box",@"inlet",@"outlet",@"object",@"canvas",@"comment"];
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
