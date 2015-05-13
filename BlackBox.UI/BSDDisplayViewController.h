//
//  BSDDisplayViewController.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BSDDisplayViewControllerDelegate <NSObject>

- (void)hideDisplayViewController:(id)sender;

@end

@interface BSDDisplayViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *closeDisplayButton;
@property (weak, nonatomic)id<BSDDisplayViewControllerDelegate>delegate;
- (IBAction)tapInCloseDisplayButton:(id)sender;

@end
