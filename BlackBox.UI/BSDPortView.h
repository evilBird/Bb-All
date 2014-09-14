//
//  BSDPortView.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BSDPortViewDelegate

- (void)tapInPortView:(id)sender;

- (NSString *)parentClass;
- (NSString *)parentId;

@end

@interface BSDPortView : UIView

- (instancetype)initWithName:(NSString *)name delegate:(id<BSDPortViewDelegate>)delegate;

@property (nonatomic,getter=isSelected)BOOL selected;
@property (nonatomic,strong)UITapGestureRecognizer *tapGesture;
@property (nonatomic,weak)id<BSDPortViewDelegate>delegate;
@property (nonatomic,strong)NSMutableArray *connectedPortViews;
@property (nonatomic,strong)NSString *portName;

- (void)addConnectionToPortView:(BSDPortView *)portView;

@end
