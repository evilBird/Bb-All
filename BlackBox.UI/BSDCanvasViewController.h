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

- (NSArray *)patchList;
- (void)syncPatch:(NSString *)patch withName:(NSString *)name;
- (void)deleteSyncedPatchWithName:(NSString *)name;

@end

@interface BSDCanvasViewController : UIViewController <BSDCanvasToolbarViewDelegate,BSDCanvasDelegate,PopoverContentTableViewControllerDelegate,UIPopoverControllerDelegate,BSDScreenDelegate>

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name description:(NSString *)description;

@property (nonatomic,strong)NSString *currentPatchName;
@property (nonatomic,strong)BSDCanvas *curentCanvas;
@property (nonatomic,strong)NSMutableArray *canvases;
@property (nonatomic,strong)NSMutableDictionary *displayViews;
@property (nonatomic,weak)id<BSDCanvasViewControllerDelegate>delegate;

@end
