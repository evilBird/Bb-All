//
//  BSDCanvasViewController.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDCanvas.h"
#import "BSDCanvasToolbarView.h"
#import "BSDScreen.h"
#import "PopoverContentTableViewController.h"

@protocol BSDCanvasViewControllerDelegate <NSObject>

- (NSDictionary *)savedPatchesSender:(id)sender;
- (NSString *)savedPatchWithName:(NSString *)name sender:(id)sender;
- (void)savePatchDescription:(NSString *)description withName:(NSString *)name sender:(id)sender;
- (void)deleteItemAtPath:(NSString *)path sender:(id)sender;
- (void)showCanvas:(BSDCanvas *)canvas sender:(id)sender;
- (void)showCanvasForCompiledPatch:(BSDCompiledPatch *)compiledPatch sender:(id)sender;
- (void)showCanvasForPatchName:(NSString *)patchName sender:(id)sender;
- (void)showCanvasForPatchDescription:(NSString *)description name:(NSString *)name sender:(id)sender;
- (void)addCanvasToStack:(id)sender;
- (void)popCanvas:(id)sender;
- (void)popCanvas:(id)sender reload:(BOOL)reload;
- (BOOL)enableHomeButton:(id)sender;

@end
@class BSDCompiledPatch;
@interface BSDCanvasViewController : UIViewController <BSDCanvasToolbarViewDelegate,BSDCanvasDelegate,PopoverContentTableViewControllerDelegate,UIPopoverControllerDelegate,BSDScreenDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logViewHeight;
@property (nonatomic,strong)BSDCanvas *canvas;
@property (nonatomic,strong)NSString *currentPatchName;
@property (nonatomic,strong)BSDCanvas *curentCanvas;
@property (nonatomic,strong)NSMutableArray *canvases;
@property (nonatomic,strong)NSMutableDictionary *displayViews;
@property (nonatomic,weak)id<BSDCanvasViewControllerDelegate>delegate;
@property (nonatomic,strong)UIView *displayView;
@property (nonatomic,strong)BSDCompiledPatch *childPatch;
@property (nonatomic,strong)NSDictionary *configuration;
@property (strong, nonatomic) IBOutlet UIImageView *displayPreviewImageView;
@property (nonatomic)BOOL displayDisabled;

- (IBAction)clearLog:(id)sender;
- (IBAction)handleLogControlPan:(id)sender;
- (NSString *)emptyCanvasDescription;
- (void)configureWithData:(id)data;

@end
