//
//  BSDCompiledPatch.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDObjectDescription.h"
#import "BSDPortConnectionDescription.h"
#import "BSDPatchInlet.h"
#import "BSDPatchOutlet.h"
@class BSDCanvas;
@protocol BSDCompiledPatchDelegate

- (UIView *)superviewForCompiledPatch:(id)sender;
- (CALayer *)superlayerForCompiledPatch:(id)sender;

@end

@interface BSDCompiledPatch : BSDObject
@property (nonatomic,strong)NSArray *creationArgs;
@property (nonatomic,strong)BSDCanvas *canvas;
@property (nonatomic,strong)NSString *patchName;
- (void)reloadPatch:(NSString *)desc;

//@property (nonatomic,strong)BSDPatchInlet *patchInlet;
//@property (nonatomic,strong)BSDPatchOutlet *patchOutlet;
//@property (nonatomic,weak)id<BSDCompiledPatchDelegate>delegate;

@end
