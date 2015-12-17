//
//  ObjectView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbBoxView.h"
#import "BbObject+Decoder.h"

@class NSView;

@interface ObjectView : NSObject

- (instancetype)initWithInlets:(NSUInteger)inlets
                       outlets:(NSUInteger)outlets
                          text:(NSString *)text
                      position:(CGPoint)position
                     superview:(id)superview;

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description superview:(id)superview;
+ (BbObject *)objectWithText:(NSString *)text superview:(id)superview;


@property (nonatomic,readonly)id <BbEntityView>view;

@end
