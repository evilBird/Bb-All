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
- (void)saveCurrentPatch;
- (void)savePatch:(NSDictionary *)patch withName:(NSString *)name;
- (void)saveAbstraction:(NSDictionary *)abtraction withName:(NSString *)name;
- (void)loadAbstraction:(NSString *)abstraction;

@end

@interface BSDCanvas : UIView<BSDBoxDelegate>

@property (nonatomic,strong)NSMutableArray *graphBoxes;
@property (nonatomic,strong)NSMutableDictionary *boxes;
@property (nonatomic,strong)NSMutableDictionary *selectedBoxes;
@property (nonatomic,strong)NSMutableDictionary *copiedBoxes;
@property (nonatomic,strong)UITapGestureRecognizer *singleTap;
@property (nonatomic,strong)UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong)id<BSDCanvasDelegate>delegate;
@property (nonatomic)BSDCanvasEditState editState;

- (NSDictionary *)currentPatch;
- (NSString *)canvasId;
- (void)loadPatchWithDictionary:(NSDictionary *)dictionary;
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
- (void)addCanvasBox;

@end
