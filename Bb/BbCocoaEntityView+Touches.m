//
//  BbCocoaEntityView+Touches.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView+Touches.h"
#import "BbBase.h"

@implementation BbCocoaEntityView (Touches)

- (id)clickDown:(NSEvent *)theEvent
{
    switch (theEvent.clickCount) {
        case 1:
            if (self.selected) {
                self.selected = NO;
            }else{
                self.selected = YES;
            }
            break;
        case 2:
            if (self.editing) {
                self.editing = NO;
            }else{
                self.editing = YES;
            }
            break;
        default:
            break;
    }
    
    if (self.selected) {
        return self;
    }
    
    return nil;
}

- (id)clickUp:(NSEvent *)theEvent
{
    if (theEvent.clickCount == 0) {
        self.selected = NO;
    }
    
    if (self.selected) {
        return self;
    }
    return nil;
}

- (id)boundsWereEntered:(NSEvent *)theEvent
{
    return nil;
}

- (id)boundsWereExited:(NSEvent *)theEvent
{
    return nil;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *theKey = theEvent.characters;
    if ([theKey isEqualToString:@"\x7f"] && self.selected) {
        [self.entity.parent removeChildObject:(BbObject *)self.entity];
    }
}

- (BbViewType)viewType
{
    return BbViewType_Object;
}

@end
