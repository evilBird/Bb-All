//
//  BSDEstimatedPointView.h
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/19/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDCreate.h"

@interface BSDEstimatedPointView : BSDObject

@property (nonatomic,strong)BSDInlet *center;
@property (nonatomic,strong)BSDInlet *alpha;
@property (nonatomic,strong)BSDPrependKey *prependAlpha;
@property (nonatomic,strong)BSDPrependKey *prependCenter;
@property (nonatomic,strong)BSDView *mainView;

- (instancetype)initWithUIView:(UIView *)view;

- (UIView *)view;

@end
