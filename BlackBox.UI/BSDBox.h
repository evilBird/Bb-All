//
//  BSDBox.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDPortView.h"
#import "BSDObject.h"
#import "BSDPortConnectionDescription.h"


@protocol BSDBoxDelegate

- (void)box:(id)sender portView:(id)portView drawLineToPoint:(CGPoint)point;
- (void)box:(id)sender portView:(id)portView endedAtPoint:(CGPoint)point;
- (void)box:(id)sender instantiateObjectWithName:(NSString *)name;
- (void)boxDidMove:(id)sender;

@end

@interface BSDBox : UIView <BSDPortViewDelegate> {
    
    BSDPortView *selectedPort;
    BOOL kAllowEdit;
}

@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong)NSMutableArray *outletViews;
@property (nonatomic,strong)NSMutableArray *inletViews;
@property (nonatomic,strong)NSString *className;
@property (nonatomic,weak)id<BSDBoxDelegate>delegate;
@property (nonatomic)BOOL selected;
@property (nonatomic,strong)id object;
@property (nonatomic,strong)NSArray *creationArguments;

- (void)makeConnectionWithDescription:(BSDPortConnectionDescription *)description;
- (void)senderValueChanged:(id)value;

- (NSArray *)inlets;
- (NSArray *)outlets;
- (NSArray *)connections;
- (NSArray *)connectionVectors;
- (NSString *)uniqueId;
- (void)makeObjectInstance;
- (void)makeObjectInstanceArgs:(id)args;
- (void)updatePortFrames;

@end
