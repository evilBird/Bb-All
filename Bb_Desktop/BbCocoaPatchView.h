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
    id                     kInitView;
}

@property (nonatomic,strong)NSMutableSet *connections;
// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSArray *drawThisConnection;
@property (nonatomic,strong)NSMutableSet *selectedPortViews;

- (void)addObjectAndViewWithText:(NSString *)text;

@end
