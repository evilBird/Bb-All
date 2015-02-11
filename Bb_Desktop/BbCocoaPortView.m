//
//  BbCocoaPortView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPortView.h"
#import "NSView+Bb.h"
#import "BbObject.h"
#import "NSString+Bb.h"

@interface BbCocoaPortView ()

@end

@implementation BbCocoaPortView

#pragma mark - Public Methods

- (void)commonInit
{
    [super commonInit];
    [self updateTrackingAreas];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    
}

- (void)mouseExited:(NSEvent *)theEvent
{
    
}

- (void)setTrackingArea:(NSTrackingArea *)trackingArea
{
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
        _trackingArea = nil;
    }
    
    _trackingArea = trackingArea;
}

- (void)updateTrackingAreas
{
    CGRect bounds = self.bounds;
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:bounds
                                                                options: (NSTrackingMouseEnteredAndExited |  NSTrackingActiveAlways | NSTrackingActiveWhenFirstResponder | NSTrackingAssumeInside | NSTrackingInVisibleRect | NSTrackingMouseMoved)
                                                                  owner:self userInfo:[self userInfo]];
    self.trackingArea = trackingArea;
}

- (NSDictionary *)userInfo
{
    if (!self.entity) {
        return nil;
    }
    
    BbEntity *port = self.entity;
    BbEntity *parent =  port.parent;
    BbEntity *grandParent = parent.parent;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    CGPoint center = self.center;
    NSUInteger portIndex,parentIndex;
    
    if ([port isKindOfClass:[BbInlet class]]) {
        result[@"port_type"] = @"inlet";
    }else if ([port isKindOfClass:[BbOutlet class]]){
        result[@"port_type"] = @"outlet";
    }else{
        result[@"port_type"] = @"unknown";
    }
    
    result[@"port_id"] = @(port.objectId);
    
    if (parent) {
        portIndex = [parent indexInParent:port];
        result[@"port_index"] = @(portIndex);
        NSArray *types = [parent allowedTypesForPort:(BbPort *)port];
        if (types) {
            result[@"allowed_types"] = types;
        }else{
            result[@"allowed_types"] = @[[NSString encodeType:@encode(id)]];
        }
        
        NSString *class = [parent className];
        if (class) {
            result[@"parent_class"] = class;
        }else{
            result[@"parent_class"] = @"Well it's not a duck.";
        }
        
        result[@"parent_id"] = @(parent.objectId);
        
    }else{
        result[@"port_index"] = @(-1);
        result[@"allowed_types"] = @[[NSString encodeType:@encode(id)]];
        result[@"parent_class"] = @"Well it's not a duck.";
        result[@"parent_id"] = @(-1);
    }

    if (grandParent) {
        parentIndex = [grandParent indexInParent:parent];
        NSView *gp = (NSView *)grandParent.view;
        center = [self convertPoint:center toView:gp];
        result[@"parent_index"] = @(parentIndex);
        result[@"patch_id"] = @(grandParent.objectId);
    }else{
        result[@"parent_index"] = @(-1);
        result[@"patch_id"] = @(-1);
    }
    
    result[@"center"] = @[@([NSView roundFloat:center.x]),@([NSView roundFloat:center.y])];
    return result;
}

#pragma mark - Overrides
- (NSColor *)defaultColor
{
    return [NSColor whiteColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.7 alpha:1];
}

@end
