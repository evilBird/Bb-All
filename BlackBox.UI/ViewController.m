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

@property (nonatomic,strong)BSDCanvas *canvas;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic)CGFloat previousScale;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIPopoverController *myPopoverController;
@property (nonatomic)CGPoint lastTouchLocation;

- (IBAction)tapInSwitchViewButton:(id)sender;
- (IBAction)savePatchRequested:(id)sender;
- (IBAction)loadPatchRequested:(id)sender;
- (IBAction)clearCurrentPatchRequested:(id)sender;
- (IBAction)tapInAddButton:(id)sender;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"View";
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

            }
        }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.canvas;
}

- (UIView *)viewForCanvas:(id)canvas
{
    return self.view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapInSwitchViewButton:(id)sender {
    
    BOOL willRemove;
    CGRect frame = self.view.bounds;

    if (!self.scrollView.superview) {
        willRemove = NO;
        frame.origin.y = self.view.bounds.size.height;
        self.scrollView.frame = frame;
        [self.view insertSubview:self.scrollView belowSubview:self.toolbar];
        frame = self.view.bounds;
    }else{
        willRemove = YES;
        frame.origin.y = self.view.bounds.size.height;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.frame = frame;
    }];
    if (willRemove)
    {
        self.title = @"View";
        [self.scrollView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
    }else{
        self.title = @"Patch";
    }
}

- (IBAction)savePatchRequested:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Save Patch"
                                                   message:@"Enter a name for this patch"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        [self savePatchWithName:name];
    }
}

- (IBAction)loadPatchRequested:(id)sender {
    
    if (self.myPopoverController == nil) {
        PopoverContentTableViewController *sp = [self savedPatchesTableViewController];
        
        self.myPopoverController = [self popoverControllerWithContentViewController:sp];
        [self.myPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }else{
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }
}

- (IBAction)clearCurrentPatchRequested:(id)sender {
    
    [self.canvas clearCurrentPatch];
}

- (IBAction)tapInAddButton:(id)sender {
    
    if (self.myPopoverController == nil) {
        PopoverContentTableViewController *sp = [self addObjectsTableViewController];
        
        self.myPopoverController = [self popoverControllerWithContentViewController:sp];
        [self.myPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }else{
        
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }
}

- (void)itemWasSelected:(NSString *)patchName
{
    NSArray *objects = @[@"bang box",@"number box",@"message box",@"inlet",@"outlet"];
    if ([objects containsObject:patchName]) {
        if ([patchName isEqualToString:@"bang box"]) {
            [self.canvas addBangBoxAtPoint:[self getObjectPlacement]];
        }else if ([patchName isEqualToString:@"number box"]){
            [self.canvas addNumberBoxAtPoint:[self getObjectPlacement]];
        }else if ([patchName isEqualToString:@"message box"]){
            [self.canvas addMessageBoxAtPoint:[self getObjectPlacement]];
        }else if ([patchName isEqualToString:@"inlet"]){
            [self.canvas addInletBoxAtPoint:[self getObjectPlacement]];
        }else if ([patchName isEqualToString:@"outlet"]){
            [self.canvas addOutletBoxAtPoint:[self getObjectPlacement]];
        }
        
    }else{
        [self loadSavedPatchWithName:patchName];
    }
    [self.myPopoverController dismissPopoverAnimated:YES];
    self.myPopoverController = nil;
}

- (CGPoint)getObjectPlacement
{
    CGPoint offset = self.scrollView.contentOffset;
    CGPoint canvasCenter = self.canvas.center;
    CGPoint point = canvasCenter;
    point.x += offset.x;
    point.y += offset.y;
    
    return point;
}

- (PopoverContentTableViewController *)savedPatchesTableViewController
{
    PopoverContentTableViewController *sptvc = [[PopoverContentTableViewController alloc]initWithStyle:UITableViewStylePlain];
    sptvc.delegate = self;
    NSDictionary *savedPatches = [NSUserDefaults valueForKey:@"patches"];
    if (savedPatches) {
        sptvc.itemNames = savedPatches.allKeys;
    }else{
        sptvc.itemNames = @[@"No saved patches"];
    }
    
    return sptvc;
}

- (PopoverContentTableViewController *)addObjectsTableViewController
{
    PopoverContentTableViewController *tvc = [[PopoverContentTableViewController alloc]initWithStyle:UITableViewStylePlain];
    tvc.delegate = self;
    tvc.itemNames = @[@"bang box",@"number box",@"message box",@"inlet",@"outlet"];
    return tvc;
}

- (UIPopoverController *)popoverControllerWithContentViewController:(UIViewController *)viewController
{
    UIPopoverController *poc = [[UIPopoverController alloc]initWithContentViewController:viewController];
    poc.delegate = self;
    return poc;
}

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
    [NSUserDefaults setUserValue:patches forKey:@"patches"];
}

- (void)loadSavedPatchWithName:(NSString *)patchName
{
    NSDictionary *saved = [NSUserDefaults valueForKey:@"patches"];
    [self.canvas clearCurrentPatch];
    [self.canvas loadPatchWithDictionary:saved[patchName]];
}


- (NSURL*) documentsDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* docs = nil;
    NSURL* app = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        docs = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    
    return docs;
}


@end
