//
//  BSDConstraints.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import <UIKit/UIKit.h>

typedef void (^PinEdgeToSuperBlock)(UIView *view);

@interface BSDPinEdgeToSuper : BSDObject

//Hot inlet: takes number representing edge to align (0,1,2,3)
//Cold inlet: takes number representing inlet amount
//Main outlet: returns a block, sent to view

@end
