//
//  BbCocoaObjectView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

static CGFloat kDefaultCocoaObjectViewWidth = 100;
static CGFloat kDefaultCocoaObjectViewHeight = 62;

@interface BbViewDescription : NSObject

@property (nonatomic,strong)    NSString        *entityViewType;
@property (nonatomic,strong)    NSString        *text;
@property (nonatomic)           NSUInteger      inlets;
@property (nonatomic)           NSUInteger      outlets;
@property (nonatomic)           CGPoint         center;

+ (NSDictionary *)textAttributes;

@end

@interface BbCocoaObjectView : BbCocoaEntityView



+ (instancetype)viewWithDescription:(BbViewDescription *)viewDescription
                           inParent:(id)parentView;


@property (nonatomic,strong)        BbViewDescription               *viewDescription;
@property (nonatomic,readonly)      NSArray                         *inletViews;
@property (nonatomic,readonly)      NSArray                         *outletViews;
@property (nonatomic,strong)        NSLayoutConstraint              *centerXConstraint;
@property (nonatomic,strong)        NSLayoutConstraint              *centerYConstraint;


@end
