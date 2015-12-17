//
//  UIView+PortViews.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BbPortViewLayoutBlock) (void);

static NSString *kPortViewsKey      =   @"portViews";   //Value is an array of UIViews to be added to calling view
static NSString *kSpacerViewsKey    =   @"spacerViews"; //Value is an array of UIViews to be added to calling view

@interface UIView (PortViews)

+ (NSDictionary *)createPortViews:(NSUInteger)numPorts;
+ (NSDictionary *)createPortViews:(NSUInteger)numPorts className:(NSString *)className;

- (void)addAndLayoutInletViews:(NSDictionary *)inletViewDictionary;
- (void)addAndLayoutOutletViews:(NSDictionary *)outletViewDictionary;

@end
