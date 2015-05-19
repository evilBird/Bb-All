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
               toPoint:(VCPoint)point;
- (void)drawPathFromPortView:(BbCocoaPortView *)portView
                     toPoint:(VCPoint)toPoint;

- (VCSize)initOffsetObjectView:(BbCocoaObjectView *)view
                         event:(UIEvent *)theEvent;

- (VCPoint)normalizePoint:(VCPoint)point;
- (VCPoint)scaleNormalizedPoint:(VCPoint)point;
- (VCPoint)offsetScaledPoint:(VCPoint)point;
- (VCPoint)myCenter;

- (NSString *)copySelected;
- (void)pasteCopied:(NSString *)copied;
- (void)abstractSelected;

@end
