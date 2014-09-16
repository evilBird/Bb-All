//
//  BSDCanvas.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDGraphBox.h"
#import "BSDCanvasCompiler.h"

@protocol BSDCanvasDelegate

- (UIView *)viewForCanvas:(id)canvas;

@end

@interface BSDCanvas : UIView<BSDBoxDelegate,BSDCanvasCompilerDelegate>

@property (nonatomic,strong)NSMutableArray *graphBoxes;
@property (nonatomic,strong)NSMutableDictionary *boxes;
@property (nonatomic,strong)UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong)UILongPressGestureRecognizer *longPress;
@property (nonatomic,strong)id<BSDCanvasDelegate>delegate;

- (NSDictionary *)currentPatch;
- (void)loadPatchWithDictionary:(NSDictionary *)dictionary;
- (void)clearCurrentPatch;

@end
