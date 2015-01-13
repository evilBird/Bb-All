//
//  BSDConstraintObject.h
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
static NSString *kAlignAxisToSuperKey = @"align_axis_to_super";
typedef void (^InstallConstraintsOnViewBlock)(UIView *view);

@interface BSDConstraintObject : BSDObject

+ (ALEdge)edgeForNumber:(NSNumber *)number;
+ (ALAxis)axisForNumber:(NSNumber *)number;
+ (ALDimension)dimensionForNumber:(NSNumber *)number;
+ (NSLayoutRelation)layoutRelationForNumber:(NSNumber *)number;
+ (UIView *)view:(UIView *)view siblingViewWithTag:(NSNumber *)number;
+ (InstallConstraintsOnViewBlock)removeConstraints;

@end


@interface BSDPinEdge2SuperView : BSDConstraintObject

//Hot inlet: takes number representing edge to align (0 = top, 1 = right, 2 = bottom, 3 = left)
//Cold inlet: takes number representing offset amount in points
//Main outlet: returns an instance of ^InstallConstraintsOnViewBlock

@end

@interface BSDAlignAxis2SuperView : BSDConstraintObject

//Hot inlet: takes a number representing axis to align (0 = horizontal, 1 = vertical, 2 = baseline)
//Cold inlet: takes number representing offset amount in points
//Main outlet: returns an instance of ^InstallConstraintsOnViewBlock

@end

@interface BSDPinEdge2ViewEdge : BSDConstraintObject

//Hot inlet: takes an array containing 2 numbers representing edges to align (0 = top, 1 = right, 2 = bottom, 3 = left). First element is edge of view target view, second element is edge of source view
//Cold inlet: takes a number representing tag of target view
//Offset inlet:  takes number representing offset amount in points
//Main outlet: returns an instance of ^InstallConstraintsOnViewBlock

@property (nonatomic,strong)BSDInlet *offsetInlet;

@end

@interface BSDAlignAxis2ViewAxis : BSDConstraintObject

@property (nonatomic,strong)BSDInlet *offsetInlet;

@end

@interface BSDPinSize : BSDConstraintObject

//Hot inlet: takes a number representing the dimension to set size on (0 = width, 1 = height)
//Cold inlet: takes a number representing the size value
//Main outlet: returns an instance of ^InstallConstraintsOnViewBlock

@end