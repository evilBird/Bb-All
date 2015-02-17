//
//  BbCocoaObjectView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

static CGFloat kDefaultCocoaObjectViewWidth = 100;
static CGFloat kDefaultCocoaObjectViewHeight = 40;

static NSString *kBbUITypeObject = @"obj";
static NSString *kBbUITypeHorizontalSlider = @"hsl";
static NSString *kBbUITypeMessage = @"msg";

@interface BbCocoaObjectView : BbCocoaEntityView

@property (nonatomic,readonly)      NSArray                         *inletViews;
@property (nonatomic,readonly)      NSArray                         *outletViews;
@property (nonatomic,readonly)      NSString                        *displayedText;


+ (instancetype)viewWithBbUIType:(id)type
                          entity:(id)entity
                     description:(id)desc
                          parent:(id)parentView;

@end
