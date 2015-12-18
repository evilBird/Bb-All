//
//  UIView+PortViews.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "UIView+PortViews.h"
#import "UIView+Layout.h"
#import "NSInvocation+Bb.h"

@implementation UIView (PortViews)

+ (NSDictionary *)createPortViews:(NSUInteger)numPorts
{
    return [UIView createPortViews:numPorts className:nil];
}

+ (NSDictionary *)createPortViews:(NSUInteger)numPorts className:(NSString *)className
{
    if ( numPorts == 0 ) {
        return nil;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableArray *tempPortViews = [NSMutableArray arrayWithCapacity:numPorts];
    NSString *class = ( nil != className ) ? className : @"UIView";
    for ( NSUInteger i = 0; i < numPorts; i ++ ) {
        id port = [NSInvocation doClassMethod:class selectorName:@"new" args:nil];
        UIView *portView = (UIView *)port;
        portView.translatesAutoresizingMaskIntoConstraints = NO;
        portView.backgroundColor = [UIColor whiteColor];
        portView.userInteractionEnabled = YES;
        portView.tag = ( i * 2 );
        [tempPortViews addObject:portView];
    }
    
    result[kPortViewsKey] = [NSArray arrayWithArray:tempPortViews];
    
    NSUInteger numSpacers = numPorts - 1;
    NSMutableArray *tempSpacerViews = [NSMutableArray arrayWithCapacity:numSpacers];
    for ( NSUInteger i = 0; i < numSpacers; i ++ ) {
        UIView *spacerView = [UIView new];
        spacerView.translatesAutoresizingMaskIntoConstraints = NO;
        spacerView.backgroundColor = [UIColor clearColor];
        spacerView.userInteractionEnabled = NO;
        spacerView.tag = ( i * 2 + 1 );
        [tempSpacerViews addObject:spacerView];
    }
    
    result[kSpacerViewsKey] = [NSArray arrayWithArray:tempSpacerViews];
    
    return result;
}

- (void)addAndLayoutPortViews:(NSDictionary *)portViewDictionary alignedToEdge:(LayoutEdge)layoutEdge
{
    NSArray *portViews = portViewDictionary[kPortViewsKey];
    NSArray *spacerViews = portViewDictionary[kSpacerViewsKey];
    NSEnumerator *spacerViewEnum = spacerViews.objectEnumerator;
    NSMutableArray *constraints = [NSMutableArray array];
    UIView *lastRightPin = nil;
    for (UIView *aPortView in portViews) {
        [self addSubview:aPortView];
        [constraints addObject:[aPortView pinWidth:30]];
        [constraints addObject:[aPortView pinHeight:20]];
        [constraints addObject:[aPortView pinEdge:layoutEdge toSuperviewEdge:layoutEdge]];
        NSUInteger tag = aPortView.tag;
        UIView *leftSpacer = ( tag > 1 ) ? ( [self viewWithTag:( tag - 1 )]) : nil;
        UIView *leftPin = ( nil != leftSpacer ) ? leftSpacer : self;
        LayoutEdge pinEdge = ( leftPin == self ) ? LayoutEdge_Left : LayoutEdge_Right;
        if ( pinEdge == LayoutEdge_Left ) {
            [constraints addObject:[leftPin pinEdge:pinEdge
                                             toEdge:LayoutEdge_Left
                                             ofView:leftPin
                                          withInset:0]];
        }else{
            [constraints addObject:[aPortView pinEdge:LayoutEdge_Left
                                               toEdge:pinEdge
                                               ofView:leftPin
                                            withInset:0]];
        }
        
        UIView *rightSpacer = [spacerViewEnum nextObject];
        
        if ( nil != rightSpacer ){
            
            [self addSubview:rightSpacer];
            
            [constraints addObject:[rightSpacer pinEdge:LayoutEdge_Top
                                                 toEdge:LayoutEdge_Top
                                                 ofView:aPortView
                                              withInset:0]];
            [constraints addObject:[rightSpacer pinEdge:LayoutEdge_Bottom
                                                 toEdge:LayoutEdge_Bottom
                                                 ofView:aPortView
                                              withInset:0]];
            [constraints addObject:[rightSpacer pinEdge:LayoutEdge_Left
                                                 toEdge:LayoutEdge_Right
                                                 ofView:aPortView
                                              withInset:0]];
            if ( nil != leftSpacer ) {
                [constraints addObject:[rightSpacer pinWidthEqualToView:leftSpacer]];
            }
            lastRightPin = rightSpacer;
        }else if ( portViews.count > 1 ){
            lastRightPin = aPortView;
        }
    }
    
    if ( nil != lastRightPin ) {
        //[constraints addObject:[lastRightPin pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right]];
        [constraints addObject:[self pinEdge:LayoutEdge_Right toEdge:LayoutEdge_Right ofView:lastRightPin withInset:0]];

    }
    
    [self addConstraints:constraints];
    
}

- (void)addAndLayoutInletViews:(NSDictionary *)inletViewDictionary
{
    [self addAndLayoutPortViews:inletViewDictionary alignedToEdge:LayoutEdge_Top];
}

- (void)addAndLayoutOutletViews:(NSDictionary *)outletViewDictionary
{
    [self addAndLayoutPortViews:outletViewDictionary alignedToEdge:LayoutEdge_Bottom];
}

@end
