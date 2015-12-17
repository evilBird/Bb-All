//
//  BSDCanvasCompiler.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BSDCompiledPatch;
@protocol BSDCanvasCompilerDelegate

- (id)canvas;

@end

@interface BSDCanvasCompiler : NSObject

+ (BSDCanvasCompiler *)compiler;

@property (nonatomic,weak)id<BSDCanvasCompilerDelegate>delegate;

- (BSDCompiledPatch *)compileCanvas;

@end
