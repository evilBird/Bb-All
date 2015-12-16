//
//  BbTouchHandler.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BbTouchView;

@protocol BbTouchHandlerDelegate <NSObject>

@end

@protocol BbTouchHandlerDataSource <NSObject>

@end

@interface BbTouchHandler : NSObject

- (instancetype)initWithTouchView:(BbTouchView *)touchView
                         delegate:(id<BbTouchHandlerDelegate>)delegate
                        datasouce:(id<BbTouchHandlerDataSource>)datasource;

@property (nonatomic,weak)            id<BbTouchHandlerDelegate>              delegate;
@property (nonatomic,weak)            id<BbTouchHandlerDataSource>            datasource;

@end
