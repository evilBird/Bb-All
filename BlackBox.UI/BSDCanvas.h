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


@end

@interface BSDCanvas : UIView<BSDBoxDelegate>

@property (nonatomic,strong)NSMutableArray *graphBoxes;
@property (nonatomic,strong)NSMutableArray *subcanvases;
@property (nonatomic,strong)NSMutableArray *inlets;
@property (nonatomic,strong)NSMutableArray *outlets;
@property (nonatomic,strong)NSMutableArray *selectedBoxes;
@property (nonatomic,strong)NSMutableArray *copiedBoxes;
@property (nonatomic,strong)UITapGestureRecognizer *singleTap;
@property (nonatomic,strong)UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong)id<BSDCanvasDelegate>delegate;
@property (nonatomic)BSDCanvasEditState editState;

- (instancetype)initWithDescription:(NSString *)desc;

- (NSString *)stringDescription;
- (NSString *)canvasId;
- (void)loadPatchWithDescription:(NSString *)description;
- (void)clearCurrentPatch;

- (void)deleteSelectedContent;
- (void)copySelectedContent;
- (void)pasteSelectedContent;
- (void)encapsulatedCopiedContentWithName:(NSString *)name;
- (void)encapsulateSelectedContent;

- (CGPoint)optimalFocusPoint;
- (void)addBangBoxAtPoint:(CGPoint)point;
- (void)addNumberBoxAtPoint:(CGPoint)point;
- (void)addMessageBoxAtPoint:(CGPoint)point;
- (void)addInletBoxAtPoint:(CGPoint)point;
- (void)addOutletBoxAtPoint:(CGPoint)point;
- (void)addGraphBoxAtPoint:(CGPoint)point;
- (void)addCommentBoxAtPoint:(CGPoint)point;

@end
