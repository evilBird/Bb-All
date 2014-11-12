//
//  BSDPatchCompiler.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/7/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
@class BSDCanvas;
@interface BSDPatchCompiler : BSDObject
@property (nonatomic,strong)BSDInlet *stringInlet;
@property (nonatomic,strong)BSDInlet *canvasInlet;
@property (nonatomic,strong)BSDOutlet *canvasOutlet;
@property (nonatomic,strong)BSDOutlet *stringOutlet;

- (NSInteger)testWithString:(NSString *)string;
- (NSString *)testPatch1;
- (NSString *)testPatch2;
- (UIView *)viewWithText:(NSString *)text canvasId:(NSNumber *)canvasId canvasArgs:(NSArray *)canvasArgs;

- (NSString *)saveCanvas:(BSDCanvas *)canvas;
- (NSString *)saveBoxes:(NSArray *)boxes;
- (NSString *)saveConnectionsBetweenBoxes:(NSArray *)boxes;
- (BSDCanvas *)restoreCanvasWithText:(NSString *)text;
- (BSDCanvas *)restoreCanvasWithText:(NSString *)text creationArgs:(NSArray *)args;
- (NSArray *)restoreBoxesWithText:(NSString *)text;

@end
