//
//  BbCocoaPortView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

static CGFloat kPortViewHeightConstraint = 10;
static CGFloat kPortViewWidthConstraint = 24;
static CGFloat kMinVerticalSpacerSize = 20;
static CGFloat kMinHorizontalSpacerSize = 10;

@interface BbCocoaPortView : BbCocoaEntityView

//@property (nonatomic,strong)NSTrackingArea *trackingArea;

- (NSDictionary *)userInfo;

@end
