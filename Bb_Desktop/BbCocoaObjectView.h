//
//  BbCocoaObjectView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

@interface BbObjectViewConfiguration : NSObject

@property (nonatomic,strong)    NSString        *entityViewType;
@property (nonatomic,strong)    NSString        *text;
@property (nonatomic)           NSUInteger      inlets;
@property (nonatomic)           NSUInteger      outlets;
@property (nonatomic)           CGPoint         center;

+ (NSDictionary *)textAttributes;

@end

@interface BbCocoaObjectView : BbCocoaEntityView

+ (instancetype)viewWithConfiguration:(BbObjectViewConfiguration *)config
                               parentView:(BbCocoaEntityView *)parentView;

- (instancetype)initWithFrame:(NSRect)frameRect
                   parentView:(BbCocoaEntityView *)parentView
                       config:(BbObjectViewConfiguration *)config;

- (instancetype)initWithCoder:(NSCoder *)coder
                   parentView:(BbCocoaEntityView *)parentView
                       config:(BbObjectViewConfiguration *)config;

@property (nonatomic,strong)        BbObjectViewConfiguration       *configuration;
@property (nonatomic,readonly)      NSArray                         *inletViews;
@property (nonatomic,readonly)      NSArray                         *outletViews;
@property (nonatomic,strong)        NSLayoutConstraint              *centerXConstraint;
@property (nonatomic,strong)        NSLayoutConstraint              *centerYConstraint;


@end
