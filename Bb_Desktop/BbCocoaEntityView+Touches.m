//
//  BbCocoaEntityView+Touches.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView+Touches.h"

@implementation BbCocoaEntityView (Touches)

- (id)clickDown:(NSEvent *)theEvent
{
    self.editing = YES;
    [self setNeedsDisplay:YES];
    return self;
}

- (id)clickUp:(NSEvent *)theEvent
{
    switch (theEvent.clickCount) {
        case 1:
            if ([self selected]) {
                [self setSelected:NO];
                [self setEditing:NO];
                [self setNeedsDisplay:YES];
                return nil;
            }else{
                [self setSelected:YES];
                [self setEditing:YES];
                [self setNeedsDisplay:YES];
                return self;
            }
            break;
        default:
            [self setSelected:NO];
            [self setEditing:NO];
            [self setNeedsDisplay:YES];
            return nil;
            break;
    }
}

- (id)boundsWereEntered:(NSEvent *)theEvent
{
    return nil;
}

- (id)boundsWereExited:(NSEvent *)theEvent
{
    return nil;
}

- (BbViewType)viewType
{
    return BbViewType_Object;
}

@end
