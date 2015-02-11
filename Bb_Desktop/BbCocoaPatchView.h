//
//  BbCocoaPatchView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"
@class BbCocoaPortView,BbCocoaObjectView;
@interface BbCocoaPatchView : BbCocoaEntityView {
    
    CGPoint                kPreviousLoc;
    BbCocoaObjectView      *kSelectedObjectView;
    BbCocoaPortView        *kSelectedPortView;
}

@property (nonatomic,strong)NSMutableSet *selectedPortViews;

- (void)addObjectAndViewWithText:(NSString *)text;

@end
