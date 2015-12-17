//
//  BbTouchHandler.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BbCanvasView;

@protocol BbTouchHandlerDelegate <NSObject>


@end

@protocol BbTouchHandlerDataSource <NSObject>

- (BOOL)canvasIsEditing:(id)sender;
- (BOOL)canvasHasActiveOutlet:(id)sender;

@end

@interface BbTouchHandler : NSObject

- (instancetype)initWithCanvasView:(BbCanvasView *)canvasView
                         delegate:(id<BbTouchHandlerDelegate>)delegate
                        datasouce:(id<BbTouchHandlerDataSource>)datasource;

@property (nonatomic,weak)            id<BbTouchHandlerDelegate>              delegate;
@property (nonatomic,weak)            id<BbTouchHandlerDataSource>            datasource;

@end
