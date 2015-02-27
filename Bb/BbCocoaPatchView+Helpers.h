//
//  BbCocoaPatchView+Helpers.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView.h"

@interface BbCocoaPatchView (Helpers)

- (void)moveEntityView:(BbCocoaEntityView *)entityView
               toPoint:(NSPoint)point;

- (void)drawPathFromPortView:(BbCocoaPortView *)portView
                     toPoint:(NSPoint)toPoint;

- (NSSize)initOffsetObjectView:(BbCocoaObjectView *)view
                         event:(NSEvent *)theEvent;

- (NSPoint)normalizePoint:(NSPoint)point;
- (NSPoint)scaleNormalizedPoint:(NSPoint)point;
- (NSPoint)offsetScaledPoint:(NSPoint)point;
- (NSPoint)myCenter;

- (NSString *)copySelected;
- (void)pasteCopied:(NSString *)copied;
- (void)abstractSelected;

@end
