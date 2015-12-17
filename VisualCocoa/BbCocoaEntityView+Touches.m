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

- (id)clickDown:(VCEvent *)theEvent
{
#if TARGET_OS_IPHONE
    switch (theEvent.allTouches.count) {

#else
    switch (theEvent.clickCount) {

#endif
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

- (id)clickUp:(VCEvent *)theEvent
{
#if TARGET_OS_IPHONE
    if (theEvent.allTouches.count == 0)
#else
    if (theEvent.clickCount == 0)

#endif
    {
        self.selected = NO;
    }
    
    if (self.selected) {
        return self;
    }
    return nil;
}

- (id)boundsWereEntered:(VCEvent *)theEvent
{
    return nil;
}

- (id)boundsWereExited:(VCEvent *)theEvent
{
    return nil;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(VCEvent *)theEvent
{
#if TARGET_OS_IPHONE
        
#else
        NSString *theKey = theEvent.characters;
        if ([theKey isEqualToString:@"\x7f"] && self.selected) {
            [self.entity.parent removeChildObject:(BbObject *)self.entity];
        }
#endif
        
}

- (BbViewType)viewType
{
    return BbViewType_Object;
}

@end
