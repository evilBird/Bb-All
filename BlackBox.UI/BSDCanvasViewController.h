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
#import "PopoverContentTableViewController.h"

@protocol BSDCanvasViewControllerDelegate <NSObject>


@end

@interface BSDCanvasViewController : UIViewController <BSDCanvasToolbarViewDelegate,BSDCanvasDelegate,PopoverContentTableViewControllerDelegate,UIPopoverControllerDelegate>

- (instancetype)initWithPatchName:(NSString *)patchName delegate:(id<BSDCanvasViewControllerDelegate>)delegate;

@property (nonatomic,strong)NSString *currentPatchName;
@property (nonatomic,strong)BSDCanvas *canvas;
@property (nonatomic,strong)NSDictionary *patch;
@property (nonatomic,weak)id<BSDCanvasViewControllerDelegate>delegate;

@end
