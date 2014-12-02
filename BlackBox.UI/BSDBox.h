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
#import "BSDObjectDescription.h"
#import "BSDPortConnectionDescription.h"
#import "BSDTextField.h"
#import "BSDCompiledPatch.h"

@class BSDCanvas;
@protocol BSDBoxDelegate

- (void)box:(id)sender portView:(id)portView drawLineToPoint:(CGPoint)point;
- (void)box:(id)sender portView:(id)portView endedAtPoint:(CGPoint)point;
- (void)boxDidMove:(id)sender;
- (NSString *)canvasId;
- (NSArray *)creationArgArray;
- (id)boxWithUniqueId:(NSString *)uniqueId;
- (UIView *)displayViewForBox:(id)sender;
- (NSString *)getClassNameForText:(NSString *)text;

@end

@interface BSDBox : UIView <BSDPortViewDelegate,UIGestureRecognizerDelegate,BSDCompiledPatchDelegate> {
    
    BSDPortView *selectedPort;
    BOOL kAllowEdit;
    BOOL kReinit;
}

@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong)NSMutableArray *outletViews;
@property (nonatomic,strong)NSMutableArray *inletViews;
@property (nonatomic,strong)NSString *className;
@property (nonatomic,weak)id<BSDBoxDelegate>delegate;
@property (nonatomic)BOOL selected;
@property (nonatomic,strong)id object;
@property (nonatomic,strong)id creationArguments;
@property (nonatomic,strong)NSString *argString;
@property (nonatomic,strong)NSString *boxClassString;
@property (nonatomic,strong)NSString *assignedId;
@property (nonatomic,strong)UIColor *defaultColor;
@property (nonatomic,strong)UIColor *selectedColor;
@property (nonatomic,strong)UIColor *currentColor;
@property (nonatomic,strong)NSString *canvasId;
@property (nonatomic,strong)NSArray *canvasCreationArgs;
@property (nonatomic,strong)NSValue *translation;

- (NSString *)getDescription;

- (instancetype)initWithDesc:(NSString *)desc;
- (instancetype)initWithDescription:(BSDObjectDescription *)desc;
- (void)makeConnectionWithDescription:(BSDPortConnectionDescription *)description;
- (void)connectOutlet:(NSInteger)outletIndex toInlet:(NSInteger)inletIndex inBox:(BSDBox *)box;

- (void)initializeWithText:(NSString *)text;
- (void)createPortViewsForObject:(id)object;

- (void)updateInletViews;
- (void)updateOutletViews;

- (NSArray *)inlets;
- (NSArray *)outlets;
- (NSArray *)connections;
- (NSArray *)connectionVectors;
- (NSString *)uniqueId;
- (NSString *)boxClassName;
- (void)setSelectedPortView:(BSDPortView *)portview;
- (id)objectDescription;
- (NSArray *)connectionDescriptions;
- (id)makeCreationArgs;
- (void)makeObjectInstance;
- (void)makeObjectInstanceArgs:(id)args;
- (void)tearDown;
- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification;
- (CGSize)minimumSize;

- (void)editingRequested;


@end
