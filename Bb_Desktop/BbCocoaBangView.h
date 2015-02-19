//
//  BbCocoaBangView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaObjectView.h"

static CGFloat kDefaultBangViewSize = 60.0;

@interface BbCocoaBangView : BbCocoaObjectView

@property (nonatomic)       BOOL  sending;

- (void)sendBang;

@end
