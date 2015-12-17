//
//  BSDCanvasToolBar.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDCanvas.h"

@protocol BSDCanvasToolbarViewDelegate <NSObject>

- (void)tapInToolBar:(id)sender item:(id)item;
- (BOOL)enableHomeButtonInToolbarView:(id)sender;

@end

@interface BSDCanvasToolbarView : UIView <UIToolbarDelegate>

@property (nonatomic,weak)id<BSDCanvasToolbarViewDelegate>delegate;
@property (nonatomic,strong)UIToolbar *toolbar;
@property (nonatomic)BSDCanvasEditState editState;
@property (nonatomic,strong)UILabel *titleLabel;

@end
