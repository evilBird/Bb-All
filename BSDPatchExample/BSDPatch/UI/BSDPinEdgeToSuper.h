//
//  BSDConstraints.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import <UIKit/UIKit.h>
#import "PureLayout.h"

static NSString *kContraintsKey = @"constraints";
static NSString *kPinEdgeToSuperKey = @"pin_edge_to_super";
typedef void (^InstallConstraintsOnViewBlock)(UIView *view);

@interface BSDPinEdgeToSuper : BSDObject

//Hot inlet: takes number representing edge to align (0 = top, 1 = right, 2 = bottom, 3 = left)
//Cold inlet: takes number representing inlet amount in points
//Main outlet: returns a block, sent to view

@end

@interface BSDAlignAxisToSuper : BSDObject

//Hot inlet takes a number representing the axis to aligh (0 = horizontal, 1 = vertical)
//Cold inlet

@end

