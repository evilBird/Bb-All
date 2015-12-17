//
//  ObjectView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ObjectView.h"
#import "ObjectView+CocoaLayout.h"
#import <Cocoa/Cocoa.h>
#import "BbParsers.h"

@interface ObjectView ()

@property (nonatomic)           NSUInteger          inlets;
@property (nonatomic)           NSUInteger          outlets;
@property (nonatomic)           NSPoint             position;
@property (nonatomic,weak)      NSView              *superview;
@property (nonatomic,strong)    NSString            *text;
@property (nonatomic,strong)    BbBoxView           *privateView;

@end

@implementation ObjectView

+ (BbObject *)objectWithText:(NSString *)text superview:(id)superview
{
    BbObjectDescription *desc = (BbObjectDescription *)[BbBasicParser descriptionWithText:text];
    return [ObjectView objectWithDescription:desc superview:superview];
}

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description superview:(id)superview
{
    BbObject *object = [BbObject objectWithDescription:description];
    BbDisplayConfiguration *config = [BbDisplayConfiguration new];
    config.inlets = object.inlets.count;
    config.outlets = object.outlets.count;
    config.text = object.className;
    NSValue *centerValue = description.UICenter;
    CGPoint center;
    [centerValue getValue:&center];
    
    ObjectView *objectView = [[ObjectView alloc]initWithInlets:object.inlets.count
                                                       outlets:object.outlets.count
                                                          text:object.className
                                                      position:center
                                                     superview:superview];
    object.view = objectView.view;
    
    return object;
}

- (instancetype)initWithInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text position:(NSPoint)position superview:(NSView *)superview
{
    self = [super init];
    if (self){
        _inlets = inlets;
        _outlets = outlets;
        _text = text;
        _position = position;
        _superview = superview;
        [self commonInit];
        [_superview addSubview:(NSView *)self.view];
    }
    
    return self;
}

- (void)commonInit
{
    NSRect frame;
    frame.size = [ObjectView frameSizeForInlets:self.inlets outlets:self.outlets text:self.text];
    frame.origin = NSZeroPoint;
    frame.origin.x += self.position.x - frame.size.width/2;
    frame.origin.y += self.position.y - frame.size.height/2;
    
    self.privateView = [[BbBoxView alloc]initWithFrame:frame];
    BbDisplayConfiguration *config = [[BbDisplayConfiguration alloc]init];
    config.frame = frame;
    config.inlets = self.inlets;
    config.outlets = self.outlets;
    config.text = [self.text copy];
    config.portSize = [ObjectView portSize];
    config.spacerSize = [ObjectView spacerSizeForConfig:config];
    self.privateView.displayConfiguration = config;
}

- (NSView *)view
{
    return self.privateView;
}

@end
