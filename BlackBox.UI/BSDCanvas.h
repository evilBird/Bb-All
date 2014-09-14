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

@interface BSDCanvas : UIView<BSDBoxDelegate,BSDCanvasCompilerDelegate>

@property (nonatomic,strong)NSMutableArray *graphBoxes;
@property (nonatomic,strong)NSMutableDictionary *boxes;
@property (nonatomic,strong)UITapGestureRecognizer *doubleTap;

@end
