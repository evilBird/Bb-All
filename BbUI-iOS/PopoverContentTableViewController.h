//
//  SavedPatchesTableViewController.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverContentTableViewControllerDelegate

- (void)itemWasSelected:(NSString *)itemName;
- (void)contentTableViewControllerWasDismissed:(id)sender;
- (void)itemWasDeleted:(NSString *)itemName;

@end

@interface PopoverContentTableViewController : UITableViewController

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSArray *itemNames;
@property (nonatomic)BOOL editEnabled;
@property (nonatomic,weak)id<PopoverContentTableViewControllerDelegate>delegate;

@end
