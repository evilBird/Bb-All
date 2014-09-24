//
//  ViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "ViewController.h"
#import "BSDCanvas.h"
#import "NSUserDefaults+HBVUtils.h"
#import "PopoverContentTableViewController.h"


@interface ViewController ()<BSDCanvasDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate,PopoverContentTableViewControllerDelegate>
{
    UIColor *kDefaultBarButtonColor;
    UIColor *kSelectedBarButtonColor;
    UIColor *kDisabledBarButtonColor;
}

@property (nonatomic,strong)BSDCanvas *canvas;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutletCollection(UIBarButtonItem) NSArray *barButtonItems;
@property (strong, nonatomic) UIPopoverController *myPopoverController;

- (IBAction)tapInBarButtonItem:(UIBarButtonItem *)sender;

@end

@implementation ViewController

#pragma mark - UIViewController overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"View";
    kDefaultBarButtonColor = [UIColor colorWithWhite:0.3 alpha:1];
    kSelectedBarButtonColor = [UIColor blueColor];
    kDisabledBarButtonColor = [UIColor colorWithWhite:0.7 alpha:1];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
        if (!self.scrollView) {

            self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
            self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, self.view.bounds.size.height * 2);
            self.scrollView.delegate = self;
            self.scrollView.minimumZoomScale = 1;
            self.scrollView.maximumZoomScale = 1;
            self.scrollView.scrollEnabled = YES;
            self.scrollView.alwaysBounceHorizontal = YES;
            self.scrollView.alwaysBounceVertical = YES;
            self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            
            if (!self.canvas) {
                CGRect rect;
                rect.origin = self.scrollView.bounds.origin;
                rect.size = self.scrollView.contentSize;
                self.canvas = [[BSDCanvas alloc]initWithFrame:rect];
                self.canvas.delegate = self;
                [self.scrollView addSubview:self.canvas];
                [self.view insertSubview:self.scrollView belowSubview:self.toolbar];
                [self updateBarButtonItemsForEditState:BSDCanvasEditStateDefault];
                //[NSUserDefaults setUserValue:[NSMutableDictionary dictionary] forKey:@"patches"];

            }
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - BSDCanvas Delegate
- (UIView *)viewForCanvas:(id)canvas
{
    return self.view;
}

- (void)canvas:(id)canvas editingStateChanged:(BSDCanvasEditState)editState
{
    [self updateBarButtonItemsForEditState:editState];
}

#pragma mark - handle bar button item taps

- (IBAction)tapInBarButtonItem:(UIBarButtonItem *)sender {
    
    switch (sender.tag) {
        case 0:
            [self showSavePatchAlertView];
            break;
        case 1:
            [self showSavedPatchesPopoverFromBarButtonItem:sender];
            break;
        case 2:
            [self clearCanvas];
            break;
        case 3:
            [self showAddBoxesPopoverFromBarButtonItem:sender];
            break;
        case 4:
            [self tapInEditBarButtonItem:sender];
            break;
        case 5:
            [self tapInDeleteBarButtonItem:sender];
            break;
        case 6:
            [self tapInCopyBarButtonItem:sender];
            break;
        case 7:
            [self tapInPasteBarButtonItem:sender];
            break;
        case 8:
            [self toggleCanvasVisibility];
            break;
            
        default:
            break;
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

- (void)clearCanvas
{
    [self.canvas clearCurrentPatch];
    for (UIView *sub in self.view.subviews) {
        
        if (sub != self.scrollView && sub != self.canvas && sub != self.toolbar && ![sub isKindOfClass:[UIBarButtonItem class]]) {
            [sub removeFromSuperview];
        }
    }
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

- (void)tapInEditBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.canvas.editState == 0) {
        self.canvas.editState = BSDCanvasEditStateEditing;
        sender.tintColor = kSelectedBarButtonColor;
        sender.title = @"Editing";
    }else{
        self.canvas.editState = BSDCanvasEditStateDefault;
        sender.tintColor = kDefaultBarButtonColor;
        sender.title = @"Edit";
    }
}

- (void)tapInDeleteBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.canvas.editState > 1) {
        [self.canvas deleteSelectedContent];
        self.canvas.editState = 1;
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

- (void)toggleCanvasVisibility
{
    CGFloat newAlpha = 0;
    if (self.scrollView.alpha < 1) {
        newAlpha = 1;
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.scrollView.alpha = newAlpha;
                     }];
}

#pragma mark - editing state management

- (void)updateBarButtonItemsForEditState:(BSDCanvasEditState)editState
{
    if (editState == BSDCanvasEditStateDefault) {
        self.canvas.editState = BSDCanvasEditStateDefault;
        [self.barButtonItems[4] setTintColor:kDefaultBarButtonColor];
        [self.barButtonItems[4] setTitle:@"Edit"];
        [self.barButtonItems[5] setTintColor:kDisabledBarButtonColor];
        [self.barButtonItems[6] setTintColor:kDisabledBarButtonColor];
        [self.barButtonItems[7] setTintColor:kDisabledBarButtonColor];
    }else if (editState == BSDCanvasEditStateEditing){
        self.canvas.editState = BSDCanvasEditStateEditing;
        [self.barButtonItems[4] setTintColor:kSelectedBarButtonColor];
        [self.barButtonItems[4] setTitle:@"Editing"];
        [self.barButtonItems[5] setTintColor:kDisabledBarButtonColor];
        [self.barButtonItems[6] setTintColor:kDisabledBarButtonColor];
        [self.barButtonItems[7] setTintColor:kDisabledBarButtonColor];
    }else if (editState == BSDCanvasEditStateContentSelected){
        [self.barButtonItems[4] setTintColor:kSelectedBarButtonColor];
        [self.barButtonItems[4] setTitle:@"Editing"];
        [self.barButtonItems[5] setTintColor:kDefaultBarButtonColor];
        [self.barButtonItems[6] setTintColor:kDefaultBarButtonColor];
        [self.barButtonItems[7] setTintColor:kDisabledBarButtonColor];
    }else if (editState == BSDCanvasEditStateContentCopied){
        [self.barButtonItems[4] setTintColor:kSelectedBarButtonColor];
        [self.barButtonItems[4] setTitle:@"Editing"];
        [self.barButtonItems[5] setTintColor:kDefaultBarButtonColor];
        [self.barButtonItems[6] setTintColor:kDefaultBarButtonColor];
        [self.barButtonItems[7] setTintColor:kDefaultBarButtonColor];
    }
}

#pragma mark - patch management

- (void)savePatchWithName:(NSString *)patchName
{
    if (!patchName) {
        return;
    }
    
    NSDictionary *patch = [self.canvas currentPatch];
    NSMutableDictionary *patches = [[NSUserDefaults valueForKey:@"patches"]mutableCopy];
    if (!patches) {
        patches = [NSMutableDictionary dictionary];
    }
    patches[patchName] = patch;
    self.currentPatchName = patchName;
    [NSUserDefaults setUserValue:patches forKey:@"patches"];
}

- (void)loadSavedPatchWithName:(NSString *)patchName
{
    NSDictionary *saved = [NSUserDefaults valueForKey:@"patches"];
    [self.canvas clearCurrentPatch];
    self.currentPatchName = patchName;
    [self.canvas loadPatchWithDictionary:saved[patchName]];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [self savePatchWithName:name];
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
    NSArray *objects = @[@"bang box",@"number box",@"message box",@"object",@"inlet",@"outlet"];
    if ([objects containsObject:patchName]) {
        CGPoint point = [self.canvas optimalFocusPoint];
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
        }
        
    }else{
        
        [self loadSavedPatchWithName:patchName];
    }
    
    [self.myPopoverController dismissPopoverAnimated:YES];
    self.myPopoverController = nil;
}

#pragma mark - Utitlity methods

- (PopoverContentTableViewController *)savedPatchesTableViewController
{
    PopoverContentTableViewController *sptvc = [[PopoverContentTableViewController alloc]initWithStyle:UITableViewStylePlain];
    sptvc.delegate = self;
    NSDictionary *savedPatches = [NSUserDefaults valueForKey:@"patches"];
    if (savedPatches) {
        NSMutableArray *arr = [savedPatches.allKeys mutableCopy];
        sptvc.itemNames = [arr sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }else{
        sptvc.itemNames = @[@"No saved patches"];
    }
    
    return sptvc;
}

- (PopoverContentTableViewController *)addObjectsTableViewController
{
    PopoverContentTableViewController *tvc = [[PopoverContentTableViewController alloc]initWithStyle:UITableViewStylePlain];
    tvc.delegate = self;
    tvc.itemNames = @[@"bang box",@"number box",@"message box",@"inlet",@"outlet",@"object"];
    return tvc;
}

- (UIPopoverController *)popoverControllerWithContentViewController:(UIViewController *)viewController
{
    UIPopoverController *poc = [[UIPopoverController alloc]initWithContentViewController:viewController];
    poc.delegate = self;
    return poc;
}



@end
