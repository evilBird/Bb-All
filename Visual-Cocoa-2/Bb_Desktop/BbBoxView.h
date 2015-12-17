//
//  TestView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BbUI.h"

@interface BbDisplayConfiguration : NSObject

@property (nonatomic,strong)    NSString        *text;
@property (nonatomic)           NSUInteger      inlets;
@property (nonatomic)           NSUInteger      outlets;
@property (nonatomic)           NSRect          frame;
@property (nonatomic)           NSSize          portSize;
@property (nonatomic)           NSSize          spacerSize;

+ (NSDictionary *)textAttributes;

@end

@interface BbPortView : NSView <BbEntityView>

@property (nonatomic)           BOOL                        selected;

@end

@interface BbBoxView : NSView <BbEntityView>

@property (nonatomic,strong)    BbDisplayConfiguration      *displayConfiguration;
@property (nonatomic)           BOOL                        selected;

@end
