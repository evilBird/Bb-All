//
//  BSDNestedPatchTableViewController.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BSDNestedPatchTableViewControllerDelegate <NSObject>

- (void)patchTableViewController:(id)sender selectedPatchWithName:(NSString *)patchName patchText:(NSString *)patchText;
- (void)patchTableViewController:(id)sender deletedItemAtPath:(NSString *)keyPath;

@end

@interface BSDNestedPatchTableViewController : UITableViewController

@property (nonatomic,strong)NSDictionary *patches;
@property (nonatomic,strong)NSString *path;
@property (nonatomic,weak)id<BSDNestedPatchTableViewControllerDelegate>delegate;

- (void)refreshData;

@end
