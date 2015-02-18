//
//  BbCocoaEntityView+Touches.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"
#import "BbCocoaPatchView+Touches.h"
@interface BbCocoaEntityView (Touches)

- (id)clickDown:(NSEvent *)theEvent;
- (id)clickUp:(NSEvent *)theEvent;
- (id)boundsWereEntered:(NSEvent *)theEvent;
- (id)boundsWereExited:(NSEvent *)theEvent;
- (BbViewType)viewType;

@end
