//
//  BSDCanvas.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDGraphBox.h"
#import "BSDObjectLookup.h"

typedef NS_ENUM(NSInteger, BSDCanvasEditState){
    BSDCanvasEditStateDefault = 0,
    BSDCanvasEditStateEditing = 1,
    BSDCanvasEditStateContentSelected = 2,
    BSDCanvasEditStateContentCopied = 3,
};

@protocol BSDCanvasDelegate

- (UIView *)viewForCanvas:(id)canvas;
- (void)canvas:(id)canvas editingStateChanged:(BSDCanvasEditState)editState;
- (void)saveDescription:(NSString *)description withName:(NSString *)name;
- (void)saveCanvas:(id)canvas description:(NSString *)description name:(NSString *)name;
- (void)setCurrentCanvas:(id)canvas;
- (void)newCanvasForPatch:(NSString *)patchName withBox:(BSDGraphBox *)graphBox;
- (void)showCanvas:(BSDCanvas *)canvas;
- (void)showCanvasForCompiledPatch:(BSDCompiledPatch *)patch;
- (CGSize)defaultCanvasSize;
- (NSString *)emptyCanvasDescription;
- (NSString *)emptyCanvasDescriptionName:(NSString *)name;


@end

@interface BSDCanvas : UIView<BSDBoxDelegate,BSDPortDelegate>

@property (nonatomic,strong)NSMutableArray *graphBoxes;
@property (nonatomic,strong)NSMutableArray *subcanvases;
@property (nonatomic,strong)NSMutableArray *inlets;
@property (nonatomic,strong)NSMutableArray *outlets;
@property (nonatomic,strong)UITapGestureRecognizer *singleTap;
@property (nonatomic,strong)UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong)NSSet *absInletViewsCache;
@property (nonatomic,strong)NSSet *absOutletViewsCache;
@property (nonatomic,strong)id<BSDCanvasDelegate>delegate;
@property (nonatomic)BSDCanvasEditState editState;
@property (nonatomic,strong)NSString *name;
@property (nonatomic)BSDCanvas *parentCanvas;
@property (nonatomic,strong)NSNumber *isDirty;
@property (nonatomic,strong)NSNumber *instanceId;
@property (nonatomic,strong)NSArray *creationArgArray;

//+ (NSString *)blankCanvasDescription;
- (void)updateCompiledInstancesWithName:(NSString *)name;
+ (CGRect)frameWithEntry:(NSString *)entry;
+ (CGRect)rectForType:(NSString *)type;
- (instancetype)initWithDescription:(NSString *)desc;
- (instancetype)initWithArguments:(id)arguments;
- (NSString *)canvasId;
- (NSString *)objectId;
- (void)tearDown;
- (void)clearCurrentPatch;
- (void)loadBang;

- (void)deleteSelectedContent;
- (void)copySelectedContent;
- (void)pasteSelectedContent;
- (void)encapsulatedCopiedContentWithName:(NSString *)name;

- (CGPoint)optimalFocusPoint;
- (void)addBangBoxAtPoint:(CGPoint)point;
- (void)addNumberBoxAtPoint:(CGPoint)point;
- (void)addMessageBoxAtPoint:(CGPoint)point;
- (void)addInletBoxAtPoint:(CGPoint)point;
- (void)addOutletBoxAtPoint:(CGPoint)point;
- (void)addGraphBoxAtPoint:(CGPoint)point;
- (void)addCommentBoxAtPoint:(CGPoint)point;
- (void)addHSliderBoxAtPoint:(CGPoint)point;

@end
